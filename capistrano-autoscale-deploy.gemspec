# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'autoscale_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-autoscale-deploy"
  spec.version       = AutoScaleDeploy::VERSION
  spec.authors       = ["Ami Mahloof"]
  spec.email         = ["ami.mahloof@gmail.com"]
  spec.summary       = %q{Get all instances in AutoScale group by AutoScale ec2 tag.}
  spec.description   = %q{Get all instances in AutoScale group by AutoScale ec2 tag.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk"
  spec.add_dependency "capistrano", "~> 2.15.5"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end