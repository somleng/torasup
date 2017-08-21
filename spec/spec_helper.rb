if ENV["START_SIMPLECOV"].to_i == 1
  require 'simplecov'
  SimpleCov.start
end

require 'torasup'

RSpec.configure do |config|
  Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}
end
