# Copyright 2013 LiveOps, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not 
# use this file except in compliance with the License.  You may obtain a copy 
# of the License at:
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the 
# License for the specific language governing permissions and limitations 
# under the License.

require 'winter/constants'
require 'winter/logger'
require 'winter/service/status'
include Process

module Winter
  class Service

    def build(winterfile, options)
      #dsl = DSL.new options
      begin
        dsl = DSL.evaluate winterfile, options
      rescue Exception=>e
        $LOG.error e
        exit
      end
      dependencies = dsl[:dependencies]
      service = dsl[:config]['service']
      service_dir = File.join(WINTERFELL_DIR,RUN_DIR,service)
      #$LOG.debug dependencies
      
      if options['clean'] and File.directory?(service_dir)
        s = Winter::Service.new
        stats = s.status
        if stats.size == 0
          FileUtils.rm_r service_dir
          $LOG.debug "Deleted service directory #{service_dir}"
        else
          stats.each do |srvs,status|
            if service == srvs && status !~ /running/i
              FileUtils.rm_r service_dir
              $LOG.debug "Deleted service directory #{service_dir}"
            end
          end
        end
      end
      
      #I hate waiting so this is going to become faster.
      max_threads = 10 #make this configurable later. 
      active_threads = 0 
      Signal.trap("CHLD") do 
        #Reap everything you possibly can.
        begin
          pid = waitpid(-1, Process::WNOHANG) 
          #puts "reaped #{pid}" if pid
          active_threads -= 1 if pid
          rescue Errno::ECHILD
            break 
        end while pid
      end

      error = false
      dependencies.each do |dep|
        while (active_threads >= max_threads) do
          $LOG.debug "Total active threads: #{active_threads}"
          #$LOG.debug "threads: #{active_threads}"
          sleep 1 
        end
        #File.join(@destination,"#{@artifact}-#{@version}.#{@package}")
        if !File.exists?(File.join(dep.destination,dep.outputFilename))
          active_threads += 1
          fork do 
            result = dep.getMaven
            error = true if result == false
          end
        else
          $LOG.info "Already have #{dep.outputFilename}"
        end
      end

      #wait for stragglers
      while (active_threads > 0) do 
        sleep 1 
        $LOG.debug "threads: #{active_threads}"
      end

      exit 99 if error
    end
  end
end
