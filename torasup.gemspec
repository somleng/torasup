
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "torasup/version"

Gem::Specification.new do |gem|
  gem.name          = "torasup"
  gem.version       = Torasup::VERSION
  gem.authors       = ["David Wilkie"]
  gem.email         = ["dwilkie@gmail.com"]
  gem.description   = '"Retuns metadata about a phone number such as operator, area code and more"'
  gem.summary       = '"Retuns metadata about a phone number such as operator, area code and more"'
  gem.homepage      = "https://github.com/dwilkie/torasup/"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "countries"
  gem.add_runtime_dependency "deep_merge"
  gem.add_runtime_dependency "phony"

  gem.add_development_dependency "codeclimate-test-reporter"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
end
