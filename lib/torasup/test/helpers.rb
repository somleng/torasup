module Torasup
  module Test
    module Helpers
      private

      def yaml_file(filename)
        raise "Override me to return the path of the full path of the yaml spec"
      end

      def pstn_data(custom_file = nil)
        return @pstn_data if @pstn_data
        custom_file = yaml_file("custom_pstn_spec.yaml") if custom_file == true
        data = load_yaml_file(yaml_file("pstn_spec.yaml"))
        @pstn_data = custom_file ? data.deeper_merge(load_yaml_file(custom_file)) : data
      end

      def with_operator_data(country_id, options = {}, &block)
        country_data(country_id, options[:with_custom_pstn_data])["operators"].each do |operator, operator_data|
          next if options[:only_registered] && !options[:only_registered][country_id].include?(operator)
          yield operator, operator_data
        end
      end

      def country_data(country_id, custom_file = nil)
        pstn_data(custom_file)[country_id] || {}
      end
    end
  end
end
