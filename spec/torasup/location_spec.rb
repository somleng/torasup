require 'spec_helper'

module Torasup
  describe Location do
    subject { Location.new("kh", "23") }

    it "should return Phnom Penh" do
      subject.area.should == "Phnom Penh"
      subject.area_code.should == "23"
    end
  end
end
