require 'spec_helper'

describe Releaf::ContentNode::ParentValidator do
  let!(:root_node) { FactoryGirl.create(:node, content_type: 'HomePage') }

  class DummyNodeParentValidatorModel < ActiveRecord::Base
    acts_as_node
    self.table_name = 'texts'
  end

  class DummyNodeParentValidator1Controller < ActionController::Base
    acts_as_node
  end

  class DummyNodeParentValidator2Controller < ActionController::Base
    acts_as_node
  end


  class DummyNodeParentValidatorNode < ActiveRecord::Base
    self.table_name = 'nodes'
    include Releaf::ContentNode
    validates_with Releaf::ContentNode::ParentValidator, for: DummyNodeParentValidatorModel, under: DummyNodeParentValidator1Controller
  end

  context "when parent is valid" do
    it "doesn't add error" do
      parent = DummyNodeParentValidatorNode.create!( FactoryGirl.attributes_for(:node, content_type: 'DummyNodeParentValidator1Controller') )
      child  = DummyNodeParentValidatorNode.new( FactoryGirl.attributes_for(:node, content_type: 'DummyNodeParentValidatorModel', parent_id: parent.id) )

      expect( child ).to be_valid
    end
  end

  context "when parent is invalid" do
    it "adds error on content_type" do
      parent = DummyNodeParentValidatorNode.create!( FactoryGirl.attributes_for(:node, content_type: 'DummyNodeParentValidator2Controller') )
      child  = DummyNodeParentValidatorNode.new( FactoryGirl.attributes_for(:node, content_type: 'DummyNodeParentValidatorModel', parent_id: parent.id) )

      expect( child ).to be_invalid
      expect( child ).to have(1).error_on(:content_type)
      expect( child.errors_on(:content_type) ).to include("invalid parent node")
    end

  end

  context "when content_type is not in child list" do
    it "doesn't add error" do
      parent = DummyNodeParentValidatorNode.create!( FactoryGirl.attributes_for(:node, content_type: 'DummyNodeParentValidator1Controller') )
      child  = DummyNodeParentValidatorNode.new( FactoryGirl.attributes_for(:node, content_type: 'DummyNodeParentValidator2Controller', parent_id: parent.id) )

      expect( child ).to be_valid
    end
  end

end
