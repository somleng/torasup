require 'spec_helper'

describe Torasup do
  describe "#prefixes" do
    let(:prefixes) { described_class.prefixes }

    context "metadata" do
      it "should include the correct min, max and pattern values" do
        with_operators do |number_parts, assertions|
          prefix = assertions["country_code"].to_s + assertions["area_code"].to_s + assertions["prefix"].to_s
          prefix_metadata = prefixes[prefix]
          local_number = assertions["local_number"]

          if subscriber_number_min = prefix_metadata["subscriber_number_min"]
            expect(local_number.to_i).to be >= subscriber_number_min
          end

          if subscriber_number_max = prefix_metadata["subscriber_number_max"]
            expect(local_number.to_i).to be <= subscriber_number_max
          end

          if subscriber_number_pattern = prefix_metadata["subscriber_number_pattern"]
            expect(local_number).to match(Regexp.new(subscriber_number_pattern))
          end
        end
      end
    end
  end
end
