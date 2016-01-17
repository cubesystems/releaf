require "rails_helper"

describe Releaf::Content::Configuration do

  class ContentConfigurationDummyNode; end;
  class ContentConfigurationDummyNodesController; end;

  def stub_config config
    allow( Releaf.application.config ).to receive(:content_resources).and_return( config )
  end

  describe "#resources" do

    it "returns a hash" do
      expect( subject.resources ).to be_a Hash
    end

    it "returns content_resources from releaf application config" do
      config = { 'Node' => { controller: 'Releaf::Content::NodesController', foo: "wat" } }
      stub_config( config )
      expect( subject.resources ).to eq config
    end

    it "caches the result" do
      expect( Releaf.application.config ).to receive(:content_resources).once.and_call_original
      subject.resources
      subject.resources
    end

    context "verifies config integrity" do

      context "when config is not a hash" do
        it "raises an error" do
          stub_config( :foo )
          expect{  subject.resources }.to raise_error Releaf::Core::Error, "Releaf.application.config.content_resources must be a Hash"
        end
      end

      context "when any of the hash keys are not strings" do
        it "raises an error" do
          stub_config( Node => { controller: 'Releaf::Content::NodesController', foo: "wat" } )
          expect{ subject.resources }.to raise_error Releaf::Core::Error, "Releaf.application.config.content_resources must have string keys"
        end
      end

      context "when any of the entries does not have a hash as a value" do
        it "raises an error" do
          stub_config( 'Node' => :foo )
          expect{ subject.resources }.to raise_error Releaf::Core::Error, "Node in Releaf.application.config.content_resources must have a hash value"
        end
      end

      context "when any of the entries does not have controller class name set" do
        it "raises an error" do
          stub_config( 'Node' => { foo: "wat" } )
          expect{ subject.resources }.to raise_error Releaf::Core::Error, "Node in Releaf.application.config.content_resources must have controller class specified as a string"
        end
      end

      context "when any of the entries does not have a string for the controller class name" do
        it "raises an error" do
          stub_config( 'Node' => { controller: Releaf::Content::NodesController, foo: "wat" } )
          expect{ subject.resources }.to raise_error Releaf::Core::Error, "Node in Releaf.application.config.content_resources must have controller class specified as a string"
        end
      end

    end

  end

  describe "#models" do

    it "returns an array of node model classes" do
      expect(subject).to receive(:model_names).and_return(['ContentConfigurationDummyNode', 'Object'])
      expect(subject.models).to eq [ContentConfigurationDummyNode, Object]
    end

  end

  describe "#model_names" do

    it "returns an array of defined node class names" do
      stub_config( 'ContentConfigurationDummyNode' => { controller: 'Releaf::Content::NodesController' } )
      expect(subject.model_names).to eq [ 'ContentConfigurationDummyNode' ]
    end

    it "caches the result" do
      expect(subject).to receive(:resources).once.and_call_original
      subject.model_names
      subject.model_names
    end

  end


  describe "#default_model" do

    it "returns the first model from #models" do
      expect(subject).to receive(:models).and_return [ :foo, :bar ]
      expect(subject.default_model).to eq :foo
    end

  end

  describe "#controllers" do

    it "returns an array of node controller classes" do
      expect(subject).to receive(:controller_names).and_return([
        'Releaf::Content::NodesController', 'Admin::OtherSite::OtherNodesController'
      ])
      expect(subject.controllers).to eq [Releaf::Content::NodesController, Admin::OtherSite::OtherNodesController]
    end


  end

  describe "#controller_names" do

    it "returns an array of defined node controller class names" do
      stub_config( {
        'Node' => { controller: 'Releaf::Content::NodesController' },
        'ContentConfigurationDummyNode' => { controller: 'ContentConfigurationDummyNodesController' }
      })
      expect(subject.controller_names).to eq [ 'Releaf::Content::NodesController', 'ContentConfigurationDummyNodesController' ]
    end

    it "caches the result" do
      expect(subject).to receive(:resources).once.and_call_original
      subject.controller_names
      subject.controller_names
    end
  end

  describe ".routing" do

    it "returns a hash with all node class names as string keys" do
      stub_config( {
        'Node' => { controller: 'Releaf::Content::NodesController' },
        'ContentConfigurationDummyNode' => { controller: 'ContentConfigurationDummyNodesController' }
      })
      result = subject.routing
      expect( result ).to be_a Hash
      expect( result.keys ).to eq ['Node', 'ContentConfigurationDummyNode' ]
    end

    context "when node has no routing defined" do
      it "returns routing hash with site and constraints set to nil" do
        stub_config( 'Node' => { controller: 'Releaf::Content::NodesController' } )
        expect(subject.routing).to eq 'Node' => { site: nil, constraints: nil }
      end
    end

    context "when node has nil values for site and constraints in routing config" do
      it "returns routing hash with site and constraints set to nil" do
        stub_config( 'Node' => {
          controller: 'Releaf::Content::NodesController',
          routing: { site: nil, constraints: nil }
        } )
        expect(subject.routing).to eq 'Node' => { site: nil, constraints: nil }
      end
    end

    context "when node has site defined in routing config" do
      it "returns the defined value in routing hash" do
        stub_config( 'Node' => {
          controller: 'Releaf::Content::NodesController',
          routing: { site: "foo" }
        } )
        expect(subject.routing).to eq 'Node' => { site: "foo", constraints: nil }
      end
    end

    context "when node has constraints defined in routing config" do
      it "returns the defined value in routing hash" do
        stub_config( 'Node' => {
          controller: 'Releaf::Content::NodesController',
          routing: { constraints: { host: /foo/ }}
        } )
        expect(subject.routing).to eq 'Node' => { site: nil, constraints: { host: /foo/ } }
      end
    end

    it "caches the result" do
      expect(subject).to receive(:resources).once.and_call_original
      subject.routing
      subject.routing
    end
  end


end