# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'winter/version'

Gem::Specification.new do |spec|
  spec.name          = "winterfell"
  spec.version       = Winter::VERSION
  spec.authors       = ["S. Mikkel Wilson"]
  spec.email         = ["swilson@liveops.com"]
  spec.description   = %q{Application and configuration bundler for OSGi apps.}
  spec.summary       = %q{Use Winterfell to describe your OSGi application and its configuration. The command line tool (winter) can be used to assemble, start, stop, and verify the application.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
