module Torasup
  class Location
    attr_accessor :country_id, :area_code, :area

    def initialize(country_id, area_code)
      @area = Torasup.area_code(country_id, area_code)
      @area_code = area_code if @area
    end
  end
end
