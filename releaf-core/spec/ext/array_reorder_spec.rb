require "rails_helper"

describe Array do
  let(:subject){ [:a, :b, :c] }

  describe "#reorder" do
    it "return reordered result for given options from `Array::Reorder` service" do
      expect(Array::Reorder).to receive(:call).with(array: subject, values: :b, options: :last).and_call_original
      expect(subject.reorder(:b, :last)).to eq([:a, :c, :b])
    end
  end
end
