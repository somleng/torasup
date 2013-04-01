module Torasup
  class Number
    attr_reader :local_number, :number

    def self.full_prefixes(conditions = {})

    end

    def initialize(phone_number)
      set_phone_number(phone_number)
    end

    def country_id
      Torasup.country_id(@country_code)
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

    def set_phone_number(number)
      @number = Phony.normalize(number)
      phony_number = split_number
      @country_code = phony_number.shift
      @local_number = phony_number.join
    end

    def split_number
      Phony.split(@number).reject { |part| part == false }
    end
  end
end
