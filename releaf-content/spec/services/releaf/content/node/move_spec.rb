require "rails_helper"

describe Releaf::Content::Node::Move do
  class DummyNodeServiceIncluder
    include Releaf::Content::Node::Service
  end

  let(:node){ Node.new }
  subject{ described_class.new(node: node, parent_id: 12) }

  describe "#call" do
    context "when parent is same" do
      it "does nothing and returns self" do
        node.parent_id = 12
        expect(node.class).to_not receive(:transaction)
        expect(subject.call).to eq(node)
      end
    end
  end
end
