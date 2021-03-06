require "yaml"
require "phony"
require "countries"
require "deep_merge/rails_compat"

require "torasup/version"
require "torasup/configuration"
require "torasup/phone_number"
require "torasup/operator"
require "torasup/location"

module Torasup
  ALL_PREFIXES_KEYS = ["*", "all"].freeze
  DEFAULT_OPERATOR_PREFIX_MIN = "10".freeze
  DEFAULT_OPERATOR_PREFIX_MAX = "99".freeze

  module Test
    autoload :Helpers, "torasup/test/helpers"
  end

  class << self
    def configure
      yield(configuration)
    end

    def load_international_dialing_codes!
      @international_dialing_codes = {}
      ISO3166::Country.all.each do |country|
        dialing_code = country.country_code
        if !@international_dialing_codes[dialing_code] || configuration.default_countries.include?(country.alpha2)
          @international_dialing_codes[dialing_code] = country.alpha2
        end
      end
    end

    def load_pstn_data!
      @pstn_data = load_yaml_file(File.join(File.dirname(__FILE__), "torasup/data/pstn.yaml"))
      configuration.custom_pstn_data_files.compact.each do |pstn_data_file|
        @pstn_data.deeper_merge!(
          load_yaml_file(pstn_data_file)
        )
      end
      load_pstn_prefixes!
    end

    def country_id(country_code)
      @international_dialing_codes[country_code]&.downcase
    end

    def area_code(country_id, code)
      area_codes(country_id)[code]
    end

    def prefix_data(prefix)
      @pstn_prefixes[prefix] || {}
    end

    def registered_operators
      configuration.registered_operators
    end

    def registered_operator_prefixes
      @registered_pstn_prefixes.dup
    end

    def prefixes
      @pstn_prefixes.dup
    end

    private

    def load_pstn_prefixes!
      @pstn_prefixes = {}
      @registered_pstn_prefixes = {}
      @pstn_data.each do |country_id, country_properties|
        operators(country_id).each do |operator, operator_properties|
          operator_prefixes(country_id, operator).each do |operator_prefix, prefix_data|
            prefix_properties = operator_metadata(
              country_id, operator
            ).merge(
              prefix_defaults(country_properties, operator_properties, prefix_data)
            ).merge(prefix_data)

            @pstn_prefixes[operator_prefix] = prefix_properties
            if operator_registered?(country_id, operator)
              @registered_pstn_prefixes[operator_prefix] = prefix_properties
            end
          end
        end
      end
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def load_yaml_file(file_to_load)
      file_to_load ? YAML.load_file(file_to_load) : {}
    end

    def operator_registered?(country_id, operator)
      (registered_operators[country_id] || []).include?(operator)
    end

    def country_data(country_id)
      @pstn_data[country_id] || {}
    end

    def international_dialing_code(country_id)
      country_data(country_id)["international_dialing_code"]
    end

    def area_codes(country_id)
      country_data(country_id)["area_codes"] || {}
    end

    def operators(country_id)
      country_data(country_id)["operators"] || {}
    end

    def operator_data(country_id, operator)
      operators(country_id)[operator] || {}
    end

    def operator_metadata(country_id, operator)
      { "country_id" => country_id, "id" => operator }.merge(operator_data(country_id, operator)["metadata"] || {})
    end

    def operator_area_code_prefixes(country_id, operator)
      operator_data(country_id, operator)["area_code_prefixes"] || {}
    end

    def prefix_defaults(country_properties, operator_properties, prefix_properties)
      defaults = {}
      prefix_type = prefix_properties["type"]
      %i[min max pattern].each do |prefix_key|
        result_key = "subscriber_number_#{prefix_key}"
        default_key = "default_#{prefix_type}_#{result_key}"
        result_value = prefix_properties[result_key] || operator_properties[default_key] || country_properties[default_key]
        defaults.merge!(result_key => result_value)
      end
      defaults
    end

    def operator_mobile_prefixes(country_id, operator)
      full_prefixes = {}
      operator_data = operator_data(country_id, operator)
      if operator_data["prefixes"].is_a?(String) && ALL_PREFIXES_KEYS.include?(operator_data["prefixes"])
        operator_prefix_min = country_data(country_id).fetch("operator_prefix_min", DEFAULT_OPERATOR_PREFIX_MIN)
        operator_prefix_max = country_data(country_id).fetch("operator_prefix_max", DEFAULT_OPERATOR_PREFIX_MAX)
        prefixes = (operator_prefix_min.to_s..operator_prefix_max).to_a
      end
      prefixes ||= operator_data["prefixes"]
      prefixes ||= []
      mobile_prefixes = array_to_hash(prefixes)
      mobile_prefixes.each do |mobile_prefix, prefix_metadata|
        full_prefixes[operator_full_prefix(country_id, mobile_prefix)] = {
          "type" => "mobile",
          "prefix" => mobile_prefix
        }.merge(prefix_metadata)
      end
      full_prefixes
    end

    def operator_full_prefix(country_id, *prefixes)
      international_dialing_code(country_id) + prefixes.join
    end

    def operator_prefixes(country_id, operator)
      operator_prefixes = operator_mobile_prefixes(country_id, operator)
      area_code_prefixes = array_to_hash(operator_area_code_prefixes(country_id, operator))
      area_code_prefixes.each do |operator_area_code_prefix, prefix_metadata|
        area_codes(country_id).each do |area_code, _area|
          operator_prefixes[operator_full_prefix(country_id, area_code, operator_area_code_prefix)] = {
            "type" => "landline",
            "prefix" => operator_area_code_prefix,
            "area_code" => area_code
          }.merge(prefix_metadata)
        end
      end
      operator_prefixes
    end

    def array_to_hash(array)
      array.map { |n| n.is_a?(Hash) ? n : { n => {} } }.reduce({}, :merge)
    end
  end

  load_international_dialing_codes!
  load_pstn_data!
end
