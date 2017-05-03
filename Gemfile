source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "phony", :github => "dwilkie/phony"

# Specify your gem's dependencies in torasup.gemspec
gemspec
