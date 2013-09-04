require 'spec_helper'

describe Torasup do
  include PstnHelpers

  describe ".configure" do
    describe "#registered_operators=" do
      before do
        Torasup.stub(:load_pstn_data!)
      end

      it "should set the registered operators and clear" do
        Torasup.configure do |config|
          Torasup.should_receive(:load_pstn_data!)
          config.registered_operators.should == {}
          config.registered_operators = {"foo" => "bar"}
          config.registered_operators.should == {"foo" => "bar"}
        end
      end
    end

    describe "#register_operators(country_id, *operators)" do
      before do
        Torasup.stub(:load_pstn_data!)
      end

      it "should set the registered operators" do
        Torasup.configure do |config|
          Torasup.should_receive(:load_pstn_data!)
          config.registered_operators = {}
          config.register_operators("kh", "smart", "beeline")
          config.registered_operators.should == {"kh" => ["smart", "beeline"]}
        end
      end
    end

    describe "#default_countries=('['US', 'AU']')" do
      before do
        Torasup.stub(:load_international_dialing_codes!)
      end

      it "should set the default countries and reload the data" do
        Torasup.configure do |config|
          Torasup.should_receive(:load_international_dialing_codes!)
          config.default_countries.should == ["US", "GB", "AU", "IT", "RU", "NO"]
          config.default_countries = ["US", "GB"]
          config.default_countries.should == ["US", "GB"]
        end
      end
    end

    describe "#custom_pstn_data_file=('path_to_yaml_file.yaml')" do
      before do
        Torasup.stub(:load_pstn_data!)
      end

      it "should set a custom pstn data file and reload the data" do
        Torasup.configure do |config|
          Torasup.should_receive(:load_pstn_data!)
          config.custom_pstn_data_file.should be_nil
          config.custom_pstn_data_file = "foo.yaml"
          config.custom_pstn_data_file.should == "foo.yaml"
        end
      end
    end
  end
end
