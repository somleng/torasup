require 'spec_helper'

describe Torasup do
  describe ".configure" do
    describe "#register_operators" do
      it "should set the registered operators" do
        Torasup.configure do |config|
          config.registered_operators.should be_nil
          config.register_operators("kh", ["smart", "beeline"])
          config.registered_operators.should == {"kh" => ["smart", "beeline"]}
        end
      end
    end

    describe "#default_countries" do
      it "should set the default countries" do
        Torasup.configure do |config|
          config.default_countries.should == ["US", "GB", "AU", "IT", "RU", "NO"]
          config.default_countries = ["US", "GB"]
          config.default_countries.should == ["US", "GB"]
        end
      end
    end
  end
end
