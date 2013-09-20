module Torasup
  module Test
    module Helpers

      private

      def yaml_file(filename)
        raise "Override this method to return the full path of the yaml spec"
      end

      def load_yaml_file(file_to_load)
        file_to_load ? YAML.load_file(file_to_load) : {}
      end

      def pstn_spec(filename)
        File.join(File.dirname(__FILE__), "../../../spec/support/#{filename}")
      end

      def pstn_data(custom_spec = nil)
        if custom_spec == true
          custom_spec = pstn_spec("custom_pstn_spec.yaml")
        elsif custom_spec
          custom_spec = yaml_file(custom_spec)
        end
        data = load_yaml_file(pstn_spec("pstn_spec.yaml"))
        custom_spec ? data.deeper_merge(load_yaml_file(custom_spec)) : data
      end

      def with_operators(options = {}, &block)
        operator_assertions = {}
        with_pstn_data(options) do |country_id, country_data, country_prefix|
          operator_assertions[country_prefix] = {}
          default_assertions = {"country_code" => country_prefix}
          with_operator_data(country_id, options) do |operator, operator_data|
            default_operator_assertions = operator_data["assertions"].merge("country_id" => country_id, "id" => operator).merge(default_assertions)
            with_operator_area_codes(country_data, operator_data) do |area_code_prefix, area_code, area|
              area_code_assertions = operator_assertions[country_prefix][area_code] ||= {}
              area_code_assertions[area_code_prefix] = {}
              local_number = ("0" * (6 - area_code_prefix.length))
              unresolved_number = area_code_prefix + local_number
              area_code_assertions[area_code_prefix][local_number] = default_operator_assertions.merge(
                "area_code" => area_code, "prefix" => area_code_prefix, "local_number" => local_number
              )
            end
            with_operator_prefixes(operator_data) do |prefix|
              prefix_assertions =  operator_assertions[country_prefix][prefix] = {}
              no_area_code_assertions = prefix_assertions[nil] = {}
              local_number = ("0" * 6)
              no_area_code_assertions[local_number] = default_operator_assertions.merge(
                "prefix" => prefix, "area_code" => nil
              )
            end
          end
        end
        operator_assertions.each do |country_prefix, country_assertions|
          country_assertions.each do |area_code_or_prefix, area_code_assertions|
            area_code_assertions.each do |area_code_prefix, local_numbers|
              local_numbers.each do |local_number, assertions|
                unresolved_local_number = area_code_prefix.to_s + local_number
                yield [country_prefix, area_code_or_prefix, unresolved_local_number], assertions
              end
            end
          end
        end
      end

      def with_pstn_data(options = {}, &block)
        pstn_data(options[:with_custom_pstn_data]).each do |country_id, country_data|
          next if options[:only_registered] && !options[:only_registered].include?(country_id)
          yield country_id, country_data, country_data["prefix"]
        end
      end

      def with_operator_data(country_id, options = {}, &block)
        country_data(country_id, options[:with_custom_pstn_data])["operators"].each do |operator, operator_data|
          next if options[:only_registered] && !options[:only_registered][country_id].include?(operator)
          yield operator, operator_data
        end
      end

      def with_operator_area_codes(country_data, operator_data, &block)
        (operator_data["area_code_prefixes"] || {}).each do |area_code_prefix|
          country_data["area_codes"].each do |area_code, area|
            yield area_code_prefix, area_code, area
          end
        end
      end

      def with_operator_prefixes(operator_data, &block)
        operator_data["prefixes"].each do |prefix|
          yield prefix
        end
      end

      def country_data(country_id, custom_file = nil)
        pstn_data(custom_file)[country_id.to_s] || {}
      end

      def interpolated_assertion(assertion, interpolations = {})
        if assertion
          interpolated_result = assertion.dup
          interpolations.each do |interpolation, value|
            interpolated_result.gsub!("%{#{interpolation}}", value.to_s)
          end
          interpolated_result
        end
      end
    end
  end
end
