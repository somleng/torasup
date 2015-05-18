require 'spec_helper'

module Torasup
  describe Operator do
    include PstnHelpers

    let(:sample_operator) do
      country = pstn_data.first
      [country.first, country.last["operators"].first.first]
    end

    shared_examples_for "operator metadata" do
      it "should return the operators with their metadata" do
        operators = Operator.send(method)
        operators = Operator.send(method) # run it twice to highlight the duplication problem
        with_operators do |number_parts, assertions|
          operator = operators[assertions["country_id"]][assertions["id"]]
          expect(operator["country_id"]).to eq(assertions["country_id"])
          expect(operator["id"]).to eq(assertions["id"])
          expect(operator["prefixes"]).to eq(operator["prefixes"].uniq)
          expect(operator["prefixes"]).to include(
            assertions["country_code"].to_s + assertions["area_code"].to_s + assertions["prefix"].to_s
          )
        end
      end
    end

    describe ".all" do
      it_should_behave_like "operator metadata" do
        let(:method) { :all }
      end
    end

    describe ".registered" do
      context "given no operators have been registered" do
        before do
          clear_registered_operators
        end

        it "should return an empty hash" do
          expect(Operator.registered).to eq({})
        end
      end

      context "given one operator has been registered" do
        before do
          configure_registered_operators(sample_operator[0], sample_operator[1])
        end

        it_should_behave_like "operator metadata" do
          let(:method) { :registered }

          def with_operators(&block)
            super(:only_registered => {sample_operator[0] => [sample_operator[1]]}, &block)
          end
        end
      end
    end

    shared_examples_for "an operator" do
      it "should return all the operator metadata" do
        with_operators(options) do |number_parts, assertions|
          subject = Operator.new(*number_parts)
          assertions.each do |method, assertion|
            args = []
            args << {:interpolation => nil} unless subject.respond_to?(method)
            result = subject.send(method, *args)
            result_error = result.nil? ? "nil" : "'#{result}'"
            expect(result).to(eq(interpolated_assertion(assertion, :interpolation => nil)), "expected Operator.new('#{number_parts}').#{method} to return '#{assertion}' but got #{result_error}")
          end
        end
      end
    end

    context "using the standard data" do
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
