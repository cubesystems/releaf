require 'spec_helper'

describe Releaf::Content::NodesController do
  describe "#builder_scopes" do
    it "adds node builder scope as first scope before default builder scopes" do
      allow(subject).to receive(:node_builder_scope).and_return("xx")
      expect(subject.builder_scopes).to eq(["xx", "Releaf::Content::Nodes"])
    end
  end

  describe "#node_builder_scope" do
    it "returns node builder scope within releaf mount location scope" do
      allow(Releaf).to receive(:mount_location).and_return("admin")
      expect(subject.node_builder_scope).to eq("Admin::Nodes")

      allow(Releaf).to receive(:mount_location).and_return("")
      expect(subject.node_builder_scope).to eq("Nodes")
    end
  end
end
