require 'spec_helper'

module Torasup
  describe PhoneNumber do
    include PstnHelpers

    subject { PhoneNumber.new("123456789") }
    let(:location) { mock(Torasup::Location).as_null_object }
    let(:operator) { mock(Torasup::Operator).as_null_object }

    describe "#location" do
      it "should return an instance of Torasup::Location" do
        subject.location.should be_a(Torasup::Location)
      end
    end

    describe "#operator" do
      it "should return an instance of Torasup::Operator" do
        subject.operator.should be_a(Torasup::Operator)
      end
    end

    describe "#area_code" do
      before do
        location.stub(:area_code).and_return("123")
        Torasup::Location.stub(:new).and_return(location)
      end

      it "should delegate to location" do
        subject.area_code.should == "123"
      end
    end

    describe "#prefix" do
      before do
        operator.stub(:prefix).and_return("12")
        Torasup::Operator.stub(:new).and_return(operator)
      end

      it "should delegate to operator" do
        subject.prefix.should == "12"
      end
    end

    describe "#local_number" do
      before do
        operator.stub(:local_number).and_return("234567")
        Torasup::Operator.stub(:new).and_return(operator)
      end

      it "should delegate to operator" do
        subject.local_number.should == "234567"
      end
    end

    shared_examples_for "a phone number" do

      before do
        Torasup::Location.stub(:new).and_return(location)
        Torasup::Operator.stub(:new).and_return(operator)
      end

      it "should return all the phone number attributes" do
        with_phone_numbers(options) do |sample_number, assertions|
          area_code_or_prefix = assertions.delete("area_code_or_prefix")
          local_number = assertions.delete("local_number")

          Torasup::Location.should_receive(:new).with(assertions["country_id"], area_code_or_prefix)
          Torasup::Operator.should_receive(:new).with(assertions["country_code"], area_code_or_prefix, local_number)

          subject = PhoneNumber.new(sample_number)

          assertions.each do |method, assertion|
            result = subject.send(method)
            result_error = result.nil? ? "nil" : "'#{result}'"
            result.should(eq(assertion), "expected PhoneNumber.new('#{sample_number}').#{method} to return '#{assertion}' but got #{result_error}")
          end
        end
      end
    end

    context "using the standard data" do
      before do
        configure_with_custom_data(false)
      end

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
