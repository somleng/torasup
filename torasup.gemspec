# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'torasup/version'

Gem::Specification.new do |gem|
  gem.name          = "torasup"
  gem.version       = Torasup::VERSION
  gem.authors       = ["David Wilkie"]
  gem.email         = ["dwilkie@gmail.com"]
  gem.description   = %q{"Retuns metadata about a phone number such as operator, area code and more"}
  gem.summary       = %q{"Retuns metadata about a phone number such as operator, area code and more"}
  gem.homepage      = "https://github.com/dwilkie/torasup/"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "countries", '>= 1.1.0'
  gem.add_runtime_dependency "phony", '>= 2.15.43'
  gem.add_runtime_dependency "deep_merge"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
