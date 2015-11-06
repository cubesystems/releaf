require 'rails_helper'

describe Releaf::Content::Node::RootValidator do


  class DummyRootValidatorController < ActionController::Base
    acts_as_node
  end

  class DummyRootValidator2Controller < ActionController::Base
    acts_as_node
  end

  class DummyRootValidatorNode < ActiveRecord::Base
    self.table_name = 'nodes'
    include Releaf::Content::Node
    validates_with Releaf::Content::Node::RootValidator, allow: DummyRootValidatorController
  end


  def create_node *params
    DummyRootValidatorNode.create!( FactoryGirl.attributes_for(:node, *params) )
  end

  def build_node *params
    DummyRootValidatorNode.new( FactoryGirl.attributes_for(:node, *params) )
  end

  context "when node is allowed to be root node" do
    context "when node is a root node" do
      it "doesn't add an error" do
        root_node = build_node(content_type: 'DummyRootValidatorController')
        expect( root_node ).to be_valid
      end
    end

    context "when node is not a root node" do
      it "adds an error" do
        root_node = create_node(content_type: 'DummyRootValidatorController')
        subnode = build_node(content_type: 'DummyRootValidatorController', parent: root_node)
        expect( subnode ).to be_invalid
        expect( subnode.errors[:content_type].size ).to eq(1)
        expect( subnode.errors[:content_type] ).to include("can't be subnode")
      end
    end
  end

  context "when node is not allowed to be a root node" do
    context "when node is a root node" do
      it "adds an error" do
        root_node = build_node(content_type: 'DummyRootValidator2Controller')
        expect( root_node ).to be_invalid
        expect( root_node.errors[:content_type].size ).to eq(1)
        expect( root_node.errors[:content_type] ).to include("can't be root node")
      end
    end

    context "when node is not a root node" do
      it "doesn't add an error" do
        root_node = create_node(content_type: 'DummyRootValidatorController')
        subnode = build_node(content_type: 'DummyRootValidator2Controller', parent: root_node)

        expect( subnode ).to be_valid
      end
    end
  end


end
