require 'spec_helper'

describe Releaf::Content::NodesController do
  describe "#form_builder" do
    it "returns Releaf::Content::NodeFormBuilder" do
      expect(subject.form_builder(:edit, Node.new)).to eq(Releaf::Content::NodeFormBuilder)
    end
  end
end
