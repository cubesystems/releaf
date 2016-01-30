require 'rails_helper'

describe Releaf::Content::NodesController do

  describe ".resource_class" do
    it "looks up node class in releaf content resource configuration" do
      config = { 'OtherSite::OtherNode' => { controller: 'Releaf::Content::NodesController' } }
      allow( Releaf::Content ).to receive(:resources).and_return(config)
      expect( described_class.resource_class ).to be OtherSite::OtherNode
    end
  end
end
