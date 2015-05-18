require 'spec_helper'

describe Torasup do
  include PstnHelpers

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

    describe "#default_countries=('['US', 'AU']')" do
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

    describe "#custom_pstn_data_file=('path_to_yaml_file.yaml')" do
      before do
        allow(Torasup).to receive(:load_pstn_data!)
      end

      it "should set a custom pstn data file and reload the data" do
        Torasup.configure do |config|
          expect(Torasup).to receive(:load_pstn_data!)
          expect(config.custom_pstn_data_file).to be_nil
          config.custom_pstn_data_file = "foo.yaml"
          expect(config.custom_pstn_data_file).to eq("foo.yaml")
        end
      end
    end
  end
end
