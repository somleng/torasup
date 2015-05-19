module Torasup
  class Operator
    attr_accessor :prefix, :local_number, :area_code, :country_code

    def initialize(country_code, area_code_or_prefix, unresolved_local_number)
      @country_code = country_code
      parse_phone_number(area_code_or_prefix, unresolved_local_number)
    end

    def method_missing(method, interpolations = {})
      value = Torasup.prefix_data(full_prefix)[method.to_s]
      return value unless value.is_a?(String)
      interpolated_result = value.dup
      interpolations.each do |interpolation, interpolated_value|
        interpolated_result.gsub!("%{#{interpolation}}", interpolated_value.to_s)
      end
      interpolated_result
    end

    def self.registered
      build_metadata(:registered_operator_prefixes)
    end

    def self.all
      build_metadata(:prefixes)
    end

    private

    def parse_phone_number(area_code_or_prefix, unresolved_local_number)
      if Torasup.prefix_data(full_prefix(area_code_or_prefix, local_number_parts(unresolved_local_number)[0])).any?
        @area_code = area_code_or_prefix
        @prefix = local_number_parts(unresolved_local_number)[0]
        @local_number = local_number_parts(unresolved_local_number)[1]
      elsif Torasup.prefix_data(full_prefix(area_code_or_prefix)).any?
        @prefix = area_code_or_prefix
        @local_number = unresolved_local_number
      else
        @local_number = area_code_or_prefix + unresolved_local_number
      end
    end

    def local_number_parts(number)
      [number[0..1], number[2..-1]]
    end

    def full_prefix(*parts)
      parts = [@area_code, @prefix] if parts.empty?
      @country_code + parts.join
    end

    def self.build_metadata(operator_type)
      operators = {}
      Torasup.send(operator_type).each do |prefix, metadata|
        prefix_country_id = metadata["country_id"]
        country_operators = operators[prefix_country_id] ||= {}
        prefix_operator_id = metadata["id"]
        operator_metadata = country_operators[prefix_operator_id] ||= metadata.dup
        operator_metadata.delete("prefix")
        operator_metadata.delete("type")
        type = metadata["type"]
        typed_prefixes = operator_metadata["#{type}_prefixes"] ||= []
        typed_prefixes << prefix
      end
      operators
    end

    private_class_method :build_metadata
  end
end
