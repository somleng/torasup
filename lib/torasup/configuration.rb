class Configuration
  DEFAULT_COUNTRIES = ["US", "GB", "AU", "IT", "RU", "NO"]
  attr_accessor :registered_operators, :default_countries, :custom_pstn_data_files

  def initialize
    @default_countries = DEFAULT_COUNTRIES
  end

  def default_countries=(value)
    @default_countries = value
    Torasup.load_international_dialing_codes!
  end

  def custom_pstn_data_file=(value)
    @custom_pstn_data_files ||= []
    value ? (@custom_pstn_data_files << value) : @custom_pstn_data_files.clear
    Torasup.load_pstn_data!
  end

  def register_operators(country_code, *operators)
    registered_operators[country_code] = operators
    Torasup.load_pstn_data!
  end

  def registered_operators=(value)
    @registered_operators = value
    Torasup.load_pstn_data!
  end

  def registered_operators
    @registered_operators ||= {}
  end

  def custom_pstn_data_files
    (@custom_pstn_data_files ||= []).compact
  end
end
