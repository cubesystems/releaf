require "rails_helper"

describe Releaf::Test do
  describe ".reset!" do
    it "calls `Releaf::Content::RoutesReloader` reset" do
      # initial there are two calls
      expect(Releaf::Content::RoutesReloader).to receive(:reset!).twice
      described_class.reset!

      expect(Releaf::Content::RoutesReloader).to receive(:reset!).once
      described_class.reset!
    end
  end
end
