# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'china_ad_ip/version'

Gem::Specification.new do |spec|
  spec.name          = "china_ad_ip"
  spec.version       = ChinaAdIp::VERSION
  spec.authors       = ["suezhen"]
  spec.email         = ["sz3001@gmail.com"]
  spec.summary       = %q{locate ip, please download ip data file from http://www.iac-i.org/ }
  spec.description   = %q{locate ip }
  spec.homepage      = "https://github.com/suzhen/china_ad_ip"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  # spec.add_development_dependency "ipaddress"
end
