require 'spec_helper'

module Torasup
  describe Operator do
    include PstnHelpers

    describe ".registered_prefixes" do
      context "given no operators have been registered" do
        before do
          clear_registered_operators
        end

        it "should return an empty array" do
          Operator.registered_prefixes.should == []
        end
      end

      context "given one operator has been registered" do
        let(:operator) { sample_operator }

        before do
          configure_registered_operators(operator[0], operator[1])
          configure_with_custom_data(false)
        end

        it "should the prefixes for that operator" do
          Operator.registered_prefixes.should =~ prefixes(operator[0], operator[1])
        end
      end
    end

    describe ".all" do
      it "should return all the operators with their metadata" do
        operators = Operator.all
        operators = Operator.all # run it twice to highlight the duplication problem
        with_operators do |number_parts, assertions|
          operator = operators[assertions["country_id"]][assertions["id"]]
          operator["country_id"].should == assertions["country_id"]
          operator["id"].should == assertions["id"]
          operator["prefixes"].should == operator["prefixes"].uniq
          operator["prefixes"].should include(
            assertions["country_code"].to_s + assertions["area_code"].to_s + assertions["prefix"].to_s
          )
        end
      end
    end

    shared_examples_for "an operator" do
      it "should return all the operator metadata" do
        with_operators(options) do |number_parts, assertions|
          subject = Operator.new(*number_parts)
          assertions.each do |method, assertion|
            args = []
            args << {:interpolation => "interpolation"} unless subject.respond_to?(method)
            result = subject.send(method, *args)
            result_error = result.nil? ? "nil" : "'#{result}'"
            result.should(eq(interpolated_assertion(assertion, :interpolation => "interpolation")), "expected Operator.new('#{number_parts}').#{method} to return '#{assertion}' but got #{result_error}")
          end
        end
      end
    end

    context "using the standard data" do
      before do
        configure_with_custom_data(false)
      end

      it_should_behave_like "an operator" do
        let(:options) { {} }
      end
    end

    context "using overridden data" do
      before do
        configure_with_custom_data
      end

      it_should_behave_like "an operator" do
        let(:options) { { :with_custom_pstn_data => true } }
      end
    end
  end
end
