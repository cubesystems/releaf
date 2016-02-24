require 'rails_helper'

describe Releaf::Content::NodesController do

  describe "#features"do
    it "excludes `create another` and `search` features" do
      expect(subject.features).to_not include(:create_another, :search)
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
