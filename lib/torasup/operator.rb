module Torasup
  class Operator
    def initialize(country_id, prefix)

    end

    def self.full_prefixes(conditions = {})

    end

    def method_missing(method)
      Torasup.prefix_data(full_prefix)[method.to_s]
    end

    private

    def full_prefix_area_code(with_area_code = true)
      @country_code + (with_area_code ? @local_number[0..3] : @local_number[0..1])
    end

    def full_prefix
      Torasup.prefix_data(full_prefix_area_code).any? ? full_prefix_area_code : full_prefix_area_code(false)
    end
  end
end
