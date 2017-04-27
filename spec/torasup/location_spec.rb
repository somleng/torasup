require 'spec_helper'

module Torasup
  describe Location do
    def with_locations(options = {}, &block)
      location_assertions = {}
      with_pstn_data(options) do |country_id, country_data|
        default_assertions = {"country_id" => country_id}
        location_assertions[country_id] = {}
        (country_data["area_codes"] || []).each do |area_code, area|
          location_assertions[country_id][area_code] = default_assertions.merge("area_code" => area_code, "area" => area)
        end
      end
      location_assertions.each do |country_id, area_code_assertions|
        area_code_assertions.each do |area_code, assertions|
          yield country_id, area_code, assertions
        end
      end
    end

    shared_examples_for "a location" do
      it "should return all the location attributes" do
        with_locations(options) do |country_id, area_code, assertions|
          subject = Location.new(country_id, area_code)
          assertions.each do |method, assertion|
            result = subject.send(method)
            result_error = result.nil? ? "nil" : "'#{result}'"
            expect(result).to(eq(assertion), "expected Location.new('#{country_id}', '#{area_code}').#{method} to return '#{assertion}' but got #{result_error}")
          end
        end
      end
    end

    context "using the standard data" do
      it_should_behave_like "a location" do
        let(:options) { {} }
      end
    end

    context "using overridden data" do
      before do
        configure_with_custom_data
      end

      it_should_behave_like "a location" do
        let(:options) { { :with_custom_pstn_data => true } }
      end
    end
  end
end
