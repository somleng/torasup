module PstnHelpers
  include Torasup::Test::Helpers

  private

  def clear_pstn_data
    @pstn_data = nil
  end

  def yaml_file(filename)
    File.join(File.dirname(__FILE__), "../../spec/support/#{filename}")
  end

  def with_phone_numbers(options = {}, &block)
    phone_number_assertions = {}
    with_pstn_data(options) do |country_id, country_data, country_prefix|
      area_code_or_prefix = (10 + rand(100 - 10)).to_s
      local_number = [(100 + rand(1000 - 100)).to_s, (100 + rand(1000 - 100)).to_s]
      sample_number = "+#{country_prefix} (0) #{area_code_or_prefix}-#{local_number[0]}-#{local_number[1]}"
      normalized_number = country_prefix + area_code_or_prefix + local_number[0] + local_number[1]
      phone_number_assertions[sample_number] = {
        "number" => normalized_number, "country_id" => country_id, "country_code" => country_prefix,
        "area_code_or_prefix" => area_code_or_prefix, "local_number" => local_number.join
      }
    end
    phone_number_assertions.each do |sample_number, assertions|
      yield sample_number, assertions
    end
  end

  def with_locations(options = {}, &block)
    location_assertions = {}
    with_pstn_data(options) do |country_id, country_data|
      default_assertions = {"country_id" => country_id}
      location_assertions[country_id] = {}
      country_data["area_codes"].each do |area_code, area|
        location_assertions[country_id][area_code] = default_assertions.merge("area_code" => area_code, "area" => area)
      end
    end
    location_assertions.each do |country_id, area_code_assertions|
      area_code_assertions.each do |area_code, assertions|
        yield country_id, area_code, assertions
      end
    end
  end

  def sample_operator
    country = pstn_data.first
    [country.first, country.last["operators"].first.first]
  end

  def prefixes(country_id, *operators)
    prefix_data = []
    country_data = pstn_data[country_id]
    country_prefix = country_data["prefix"]
    operators.each do |operator|
      operator_data = country_data["operators"][operator]
      with_operator_area_codes(country_data, operator_data) do |area_code_prefix, area_code|
        prefix_data << (country_prefix + area_code + area_code_prefix)
      end
      with_operator_prefixes(operator_data) do |prefix|
        prefix_data << (country_prefix + prefix)
      end
    end
    prefix_data
  end

  def configure_with_custom_data(custom_data = true)
    custom_data_file = File.join(File.dirname(__FILE__), "../support", "/custom_pstn.yaml") if custom_data
    Torasup.configure do |config|
      config.custom_pstn_data_file = custom_data_file
    end
  end

  def configure_registered_operators(country_id, *operators)
    Torasup.configure do |config|
      config.register_operators(country_id, *operators)
    end
  end

  def clear_registered_operators
    Torasup.configure do |config|
      config.registered_operators = {}
    end
  end
end
