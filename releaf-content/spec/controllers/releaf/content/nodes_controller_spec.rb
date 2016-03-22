require 'rails_helper'

describe Releaf::Content::NodesController do

  describe "#features"do
    it "excludes `create another` and `search` features" do
      expect(subject.features).to_not include(:create_another, :search)
    end
  end

  describe "#ancestor_nodes" do
    let(:node){ Node.new }
    let(:ancestors){ Node.where(id: 1212) }

    before do
      allow(ancestors).to receive(:reorder).with(:depth).and_return(["depth_ordered_ancestors"])
    end

    context "when new node" do
      context "when node has parent" do
        it "returns parent ancestors ordered by depth alongside parent ancestor" do
          parent_node = Node.new
          node.parent = parent_node
          allow(parent_node).to receive(:ancestors).and_return(ancestors)
          expect(subject.ancestor_nodes(node)).to eq(["depth_ordered_ancestors", parent_node])
        end
      end

      context "when node has no parent" do
        it "returns empty array" do
          expect(subject.ancestor_nodes(node)).to eq([])
        end
      end
    end

    context "when persisted node" do
      it "returns resource ancestors ordered by depth" do
        allow(node).to receive(:persisted?).and_return(true)
        allow(node).to receive(:ancestors).and_return(ancestors)
        expect(subject.ancestor_nodes(node)).to eq(["depth_ordered_ancestors"])
      end
    end
  end

  describe ".resource_class" do
    it "looks up node class in releaf content resource configuration" do
      config = { 'OtherSite::OtherNode' => { controller: 'Releaf::Content::NodesController' } }
      allow( Releaf::Content ).to receive(:resources).and_return(config)
      expect( described_class.resource_class ).to be OtherSite::OtherNode
    end
  end
end
