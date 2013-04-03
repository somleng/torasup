module Torasup
  class PhoneNumber
    attr_reader :number, :country_code, :country_id, :area_code, :prefix, :local_number, :location, :operator

    def initialize(phone_number)
      parse_phone_number(phone_number)
    end

    private

    def parse_phone_number(number)
      @number = Phony.normalize(number)
      number_parts = split_number
      @country_code = number_parts.shift
      @country_id = Torasup.country_id(@country_code)
      area_code_or_prefix = number_parts.shift
      local_number = number_parts.join
      @location = Location.new(@country_id, area_code_or_prefix)
      @area_code = @location.area_code
      @operator = Operator.new(@country_code, area_code_or_prefix, local_number)
      @prefix = @operator.prefix
      @local_number = operator.local_number
    end

    def split_number
      Phony.split(@number).reject { |part| part == false }
    end
  end
end
