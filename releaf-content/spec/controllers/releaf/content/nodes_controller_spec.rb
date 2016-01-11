require 'rails_helper'

describe Releaf::Content::NodesController do

  describe ".resource_class" do
    before do
      Releaf::Content.reset_configuration
    end

    after do
      Releaf::Content.reset_configuration
    end

    it "looks up node class in releaf content resource configuration" do
      config = { 'OtherSite::OtherNode' => { controller: 'Releaf::Content::NodesController' } }
      expect( Releaf.application.config ).to receive(:content_resources).and_return(config)
      expect( described_class.resource_class ).to be OtherSite::OtherNode
    end

  end

end
