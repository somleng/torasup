require 'yaml'
require 'phony'
require 'countries'
require 'deep_merge/rails_compat'

require "torasup/version"
require "torasup/configuration"
require "torasup/phone_number"
require "torasup/operator"
require "torasup/location"

module Torasup

  module Test
    autoload :Helpers, 'torasup/test/helpers'
  end

  class << self
    def configure(&block)
      yield(configuration)
    end

    def load_international_dialing_codes!
      @international_dialing_codes = {}
      ISO3166::Country.all.each do |name, country_id|
        dialing_code = ISO3166::Country[country_id].country_code
        @international_dialing_codes[dialing_code] = country_id unless @international_dialing_codes[dialing_code] && !configuration.default_countries.include?(country_id)
      end
    end

    def load_pstn_data!
      @pstn_data = load_yaml_file(File.join(File.dirname(__FILE__), 'torasup/data/pstn.yaml')).deeper_merge(
        load_yaml_file(configuration.custom_pstn_data_file)
      )
      load_pstn_prefixes!
    end

    def country_id(country_code)
      @international_dialing_codes[country_code].downcase if @international_dialing_codes[country_code]
    end

    def area_code(country_id, code)
      area_codes(country_id)[code]
    end

    def prefix_data(prefix)
      @pstn_prefixes[prefix] || {}
    end

    def registered_prefixes
      @registered_pstn_prefixes.keys
    end

    private

    def load_pstn_prefixes!
      @pstn_prefixes = {}
      @registered_pstn_prefixes = {}
      @pstn_data.each do |country_id, country_properties|
        operators(country_id).each do |operator, operator_properties|
          operator_prefixes(country_id, operator).each do |operator_prefix, prefix_data|
            prefix_properties = operator_metadata(country_id, operator).merge(prefix_data)
            @pstn_prefixes[operator_prefix] = prefix_properties
            @registered_pstn_prefixes[operator_prefix] = prefix_properties if operator_registered?(country_id, operator)
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
      (configuration.registered_operators[country_id] || []).include?(operator)
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
      {"id" => operator}.merge(operator_data(country_id, operator)["metadata"] || {})
    end

    def operator_area_code_prefixes(country_id, operator)
      operator_data(country_id, operator)["area_code_prefixes"] || {}
    end

    def operator_mobile_prefixes(country_id, operator)
      full_prefixes = {}
      mobile_prefixes = operator_data(country_id, operator)["prefixes"] || {}
      mobile_prefixes.each do |mobile_prefix|
        full_prefixes[operator_full_prefix(country_id, mobile_prefix)] = {"prefix" => mobile_prefix}
      end
      full_prefixes
    end

    def operator_full_prefix(country_id, *prefixes)
      international_dialing_code(country_id) + prefixes.join
    end

    def operator_prefixes(country_id, operator)
      operator_prefixes = operator_mobile_prefixes(country_id, operator)
      operator_area_code_prefixes(country_id, operator).each do |operator_area_code_prefix|
        area_codes(country_id).each do |area_code, area|
          operator_prefixes[operator_full_prefix(country_id, area_code, operator_area_code_prefix)] = {"prefix" => operator_area_code_prefix}
        end
      end
      operator_prefixes
    end
  end

  load_international_dialing_codes!
  load_pstn_data!
end
