require 'spec_helper'

module Torasup
  describe Location do
    include PstnHelpers

    shared_examples_for "a location" do
      it "should return all the location attributes" do
        with_locations(options) do |country_id, area_code, assertions|
          subject = Location.new(country_id, area_code)
          assertions.each do |method, assertion|
            result = subject.send(method)
            result_error = result.nil? ? "nil" : "'#{result}'"
            result.should(eq(assertion), "expected Location.new('#{country_id}', '#{area_code}').#{method} to return '#{assertion}' but got #{result_error}")
          end
        end
      end
    end

    context "using the standard data" do
      before do
        configure_with_custom_data(false)
      end

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
