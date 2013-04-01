class Configuration
  DEFAULT_COUNTRIES = ["US", "GB", "AU", "IT", "RU", "NO"]
  attr_accessor :registered_operators, :default_countries

  def register_operators(country_code, operators)
    self.registered_operators ||= {}
    self.registered_operators[country_code] = operators
  end

  def initialize
    self.default_countries = DEFAULT_COUNTRIES
  end
end
