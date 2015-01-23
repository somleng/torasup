require 'torasup'
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end
end
