module Torasup
  class Operator
    attr_accessor :prefix, :local_number, :area_code, :country_code, :full_number

    def initialize(country_code, area_code_or_prefix, unresolved_local_number)
      self.country_code = country_code
      self.full_number = full_prefix(area_code_or_prefix, unresolved_local_number)
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
      resolve_number_parts(area_code_or_prefix, unresolved_local_number)
    end

    def resolve_number_parts(area_code_or_prefix, unresolved_local_number)
      unresolved_local_number_length = unresolved_local_number.length
      unresolved_local_number_length.times do |n|
        return if set_number_parts(
          full_prefix(area_code_or_prefix, unresolved_local_number[0..(unresolved_local_number_length - n - 1)])
        )
      end

      set_number_parts(full_prefix(area_code_or_prefix))
    end

    def set_number_parts(test_prefix)
      prefix_data = Torasup.prefix_data(test_prefix)
      self.area_code = prefix_data["area_code"]
      self.prefix = prefix_data["prefix"]
      local_number = full_number.gsub(/^#{full_prefix}/, "")
      self.local_number = local_number.empty? ? nil : local_number
      prefix_data.any?
    end

    def full_prefix(*parts)
      parts = [area_code, prefix] if parts.empty?
      country_code + parts.join
    end

    def self.build_metadata(operator_type)
      operators = {}
      Torasup.send(operator_type).each do |prefix, prefix_metadata|
        prefix_country_id = prefix_metadata["country_id"]
        country_operators = operators[prefix_country_id] ||= {}
        prefix_operator_id = prefix_metadata["id"]
        operator_metadata = country_operators[prefix_operator_id] ||= prefix_metadata.dup
        operator_metadata.delete("prefix")
        operator_metadata.delete("type")
        operator_metadata.delete("subscriber_number_min")
        operator_metadata.delete("subscriber_number_max")
        operator_metadata.delete("subscriber_number_pattern")
        type = prefix_metadata["type"]
        typed_prefixes = operator_metadata["#{type}_prefixes"] ||= {}
        typed_prefixes[prefix] = {
          "subscriber_number_min" => prefix_metadata["subscriber_number_min"],
          "subscriber_number_max" => prefix_metadata["subscriber_number_max"],
          "subscriber_number_pattern" => prefix_metadata["subscriber_number_pattern"],
        }
      end
      operators
    end

    private_class_method :build_metadata
  end
end
