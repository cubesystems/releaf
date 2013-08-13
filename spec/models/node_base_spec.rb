# encoding: UTF-8

require "spec_helper"

class FakeText < Releaf::NodeBase

end


describe Releaf::NodeBase do
  describe ".nodes" do
    it "load all nodes for class" do
      expect(Releaf::Node).to receive(:where).with(content_type: FakeText.name)
      FakeText.nodes
    end
  end
end
