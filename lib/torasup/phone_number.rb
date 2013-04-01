module Torasup
  class PhoneNumber
    attr_reader :country_code, :local_number, :number, :operator, :location

    def initialize(phone_number)
      parse_phone_number(phone_number)
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

    def parse_phone_number(number)
      @number = Phony.normalize(number)
      number_parts = split_number
      @country_code = phony_number.shift
      @country_id = Torasup.country_id(@country_code)
      area_code_or_prefix = phony_number.shift
      @location = Location.new(@country_id, area_code_or_prefix)
      @operator = Operator.new(@country_id, area_code_or_prefix)
      @local_number = phony_number.join
    end

    def split_number
      Phony.split(@number).reject { |part| part == false }
    end
  end
end
