require 'spec_helper'

describe Torasup do
  describe ".configure" do
    describe "#registered_operators=" do
      before do
        allow(Torasup).to receive(:load_pstn_data!)
      end

      it "should set the registered operators and clear" do
        Torasup.configure do |config|
          expect(Torasup).to receive(:load_pstn_data!)
          expect(config.registered_operators).to eq({})
          config.registered_operators = {"foo" => "bar"}
          expect(config.registered_operators).to eq({"foo" => "bar"})
        end
      end
    end

    describe "#register_operators(country_id, *operators)" do
      before do
        allow(Torasup).to receive(:load_pstn_data!)
      end

      it "should set the registered operators" do
        Torasup.configure do |config|
          expect(Torasup).to receive(:load_pstn_data!)
          config.registered_operators = {}
          config.register_operators("kh", "smart", "beeline")
          expect(config.registered_operators).to eq({"kh" => ["smart", "beeline"]})
        end
      end
    end

    describe "#default_countries=(value)" do
      let(:torasup_number) { Torasup::PhoneNumber.new("+1 415-234 5678") }

      context "configuring" do
        before do
          allow(Torasup).to receive(:load_international_dialing_codes!)
        end

        it "should set the default countries and reload the data" do
          Torasup.configure do |config|
            expect(Torasup).to receive(:load_international_dialing_codes!)
            expect(config.default_countries).to eq(["US", "GB", "AU", "IT", "RU", "NO"])
            config.default_countries = ["US", "GB"]
            expect(config.default_countries).to eq(["US", "GB"])
          end
        end
      end

      context "by default" do
        it { expect(torasup_number.country_id).to eq("us") }
      end

      context "overriding defaults" do
        before { Torasup.configure { |config| config.default_countries = ["CA"] } }
        it { expect(torasup_number.country_id).to eq("ca") }
      end
    end

    describe "#custom_pstn_data_file=('path_to_yaml_file.yaml')" do
      def setup_expectations
        allow(Torasup).to receive(:load_pstn_data!)
        expect(Torasup).to receive(:load_pstn_data!)
      end

      def setup_scenario
        setup_expectations
      end

      before do
        setup_scenario
      end

      context "setting a custom pstn data file" do
        it "should set a custom pstn data file and reload the data" do
          Torasup.configure do |config|
            expect(config.custom_pstn_data_files).to eq([])
            config.custom_pstn_data_file = "foo.yaml"
            expect(config.custom_pstn_data_files).to eq(["foo.yaml"])
          end
        end
      end

      context "setting the custom pstn data file to nil" do
        it "should clear the pstn data files and reload the data" do
          Torasup.configure do |config|
            expect(config.custom_pstn_data_files).to eq([])
            config.custom_pstn_data_file = "foo.yaml"
            expect(config.custom_pstn_data_files).to eq(["foo.yaml"])
            config.custom_pstn_data_file = nil
            expect(config.custom_pstn_data_files).to eq([])
          end
        end
      end
    end
  end
end
