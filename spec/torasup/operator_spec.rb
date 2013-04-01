require 'spec_helper'

module Torasup
  describe Operator do
    with_operators do |sample_number, assertions|
      context ".new('#{sample_number}')" do
        subject { Operator.new(sample_number) }

        assertions.each do |method, assertion|
          describe "##{method}" do
            it "should return '#{assertion}'" do
              assertions.each do |method, assertion|
                subject.send(method).should == assertion
              end
            end
          end
        end
      end
    end
  end
end
