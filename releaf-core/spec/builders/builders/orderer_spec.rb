require "spec_helper"

describe Releaf::Builders::Orderer, type: :module do
  class OrdererIncluder
    include Releaf::Builders::Orderer
  end
  let(:subject){ OrdererIncluder.new }

  describe "#orderer" do
    it "initializes new `Releaf::Core::ItemOrderer` instance" do
      expect(subject.orderer([:a, :b])).to be_instance_of Releaf::Core::ItemOrderer
    end

    it "initializes new `Releaf::Core::ItemOrderer` with given array values" do
      expect(subject.orderer([:a, :b]).list).to eq([:a, :b])
    end

    it "casts given value to array before passing to `Releaf::Core::ItemOrderer` constructor" do
      expect(subject.orderer(Releaf::Core::ItemOrderer.new(:a, :b)).list).to eq([:a, :b])
    end
  end
end
