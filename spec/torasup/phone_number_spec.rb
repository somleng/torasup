require 'spec_helper'

module Torasup
  describe PhoneNumber do
    def with_phone_numbers(options = {}, &block)
      phone_number_assertions = {}
      with_operators(options) do |number_parts, assertions|
        number = number_parts.join
        sample_number = "+#{number}"
        phone_number_assertions[sample_number] = {
          "number" => number, "country_id" => assertions["country_id"], "country_code" => assertions["country_code"],
          "area_code_or_prefix" => assertions["area_code"] || assertions["prefix"], "local_number" => number_parts.last
        }
      end

      phone_number_assertions.each do |sample_number, assertions|
        yield sample_number, assertions
      end
    end

    let(:phone_number) { "85512234567" }
    let(:location) { double(Torasup::Location).as_null_object }
    let(:operator) { double(Torasup::Operator).as_null_object }
    subject { PhoneNumber.new(phone_number) }

    describe "#location" do
      it "should return an instance of Torasup::Location" do
        expect(subject.location).to be_a(Torasup::Location)
      end
    end

    describe "#type" do
      context "for mobile numbers" do
        let(:phone_number) { "85512236139" }
        it { expect(subject.type).to eq("mobile") }
      end

      context "for landline numbers" do
        let(:phone_number) { "855234512345" }
        it { expect(subject.type).to eq("landline") }
      end
    end

    describe "#operator" do
      it "should return an instance of Torasup::Operator" do
        expect(subject.operator).to be_a(Torasup::Operator)
      end
    end

    describe "#area_code" do
      before do
        allow(location).to receive(:area_code).and_return("123")
        allow(Torasup::Location).to receive(:new).and_return(location)
      end

      it "should delegate to location" do
        expect(subject.area_code).to eq("123")
      end
    end

    describe "#prefix" do
      before do
        allow(operator).to receive(:prefix).and_return("12")
        allow(Torasup::Operator).to receive(:new).and_return(operator)
      end

      it "should delegate to operator" do
        expect(subject.prefix).to eq("12")
      end
    end

    describe "#local_number" do
      before do
        allow(operator).to receive(:local_number).and_return("234567")
        allow(Torasup::Operator).to receive(:new).and_return(operator)
      end

      it "should delegate to operator" do
        expect(subject.local_number).to eq("234567")
      end
    end

    shared_examples_for "a phone number" do
      before do
        allow(Torasup::Location).to receive(:new).and_return(location)
        allow(Torasup::Operator).to receive(:new).and_return(operator)
      end

      it "should return all the phone number attributes" do
        with_phone_numbers(options) do |sample_number, assertions|
          area_code_or_prefix = assertions.delete("area_code_or_prefix")
          local_number = assertions.delete("local_number")

          expect(Torasup::Location).to receive(:new).with(assertions["country_id"], area_code_or_prefix)
          expect(Torasup::Operator).to receive(:new).with(assertions["country_code"], area_code_or_prefix, local_number)

          subject = PhoneNumber.new(sample_number)

          assertions.each do |method, assertion|
            result = subject.send(method)
            result_error = result.nil? ? "nil" : "'#{result}'"
            expect(result).to(eq(assertion), "expected PhoneNumber.new('#{sample_number}').#{method} to return '#{assertion}' but got #{result_error}")
          end
        end
      end
    end

    context "using the standard data" do
      it_should_behave_like "a phone number" do
        let(:options) { {} }
      end
    end

    context "using overridden data" do
      before do
        configure_with_custom_data
      end

      it_should_behave_like "a phone number" do
        let(:options) { { :with_custom_pstn_data => true } }
      end
    end
  end
end
