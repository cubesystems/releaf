require 'rails_helper'

describe Releaf::Content::Node::SinglenessValidator do


  class DummySinglenessValidatorModel < ActiveRecord::Base
    acts_as_node
    self.table_name = 'text_pages'
  end

  class DummySinglenessValidator2Model < ActiveRecord::Base
    acts_as_node
    self.table_name = 'text_pages'
  end

  class DummySinglenessValidatorController < ActionController::Base
    acts_as_node
  end

  class DummySinglenessValidator2Controller < ActionController::Base
    acts_as_node
  end

  class DummySinglenessValidatorNode < ActiveRecord::Base
    self.table_name = 'nodes'
    include Releaf::Content::Node
    validates_with Releaf::Content::Node::SinglenessValidator, for: DummySinglenessValidatorModel
    validates_with Releaf::Content::Node::SinglenessValidator, for: DummySinglenessValidator2Controller, under: TextPage
  end


  def create_node *params
    DummySinglenessValidatorNode.create!( FactoryGirl.attributes_for(:node, *params) )
  end

  def build_node *params
    DummySinglenessValidatorNode.new( FactoryGirl.attributes_for(:node, *params) )
  end

  let!(:root_node) { create_node(content_type: 'HomePage') }


  context "when scope is entire page" do

    context "When node not mentioned in list" do
      it "doesn't add error" do
        node = build_node(content_type: 'DummySinglenessValidatorController', parent_id: root_node.id)
        expect( node ).to be_valid
      end
    end


    context "when node with given content doesn't exist in tree" do
      it "doesn't add error" do
        node = build_node(content_type: 'DummySinglenessValidatorModel', parent_id: root_node.id)
        expect( node ).to be_valid
      end
    end

    context "when node with given content exists in tree" do
      before do
        create_node(content_type: 'DummySinglenessValidatorModel', parent_id: root_node.id)
      end

      it "adds error to #content_type" do
        node = build_node(content_type: 'DummySinglenessValidatorModel', parent_id: root_node.id)
        expect( node ).to be_invalid
        expect( node.errors[:content_type].size ).to eq(1)
        expect( node.errors[:content_type] ).to include("node exists")
      end

    end

    context "when node is saved, and is only one in the tree" do
      it "doesn't add error" do
        node = create_node(content_type: 'DummySinglenessValidatorModel', parent_id: root_node.id)
        expect( node ).to be_valid
      end
    end
  end

  context "when scope is subtree" do
    context "when has ancestor in :under list" do
      let!(:grand_parent_node) { create_node(content_type: 'TextPage', parent_id: root_node.id) }
      let!(:parent_node) { create_node(content_type: 'DummySinglenessValidator2Model', parent_id: grand_parent_node.id) }

      context "when node with given content doesn't exist in subtree" do
        it "doesn't add error" do
          node = build_node(content_type: 'DummySinglenessValidator2Controller', parent_id: parent_node.id)
          expect( node ).to be_valid
        end
      end

      context "when node with given content exists in subtree" do
        before do
          create_node(content_type: 'DummySinglenessValidator2Controller', parent_id: grand_parent_node.id)
        end

        it "adds error to #content_type" do
          node = build_node(content_type: 'DummySinglenessValidator2Controller', parent_id: parent_node.id)
          expect( node ).to be_invalid
          expect( node.errors[:content_type].size ).to eq(1)
          expect( node.errors[:content_type] ).to include("node exists")
        end

      end

      context "when node is saved, and is only one in subtree" do
        it "doesn't add error" do
          node = create_node(content_type: 'DummySinglenessValidator2Controller', parent_id: parent_node.id)
          expect( node ).to be_valid
        end
      end


    end

    context "when node has no ancestor in :under list" do
      it "doesn't add error" do
        node = create_node(content_type: 'DummySinglenessValidator2Controller', parent_id: root_node.id)
        expect( node ).to be_valid
      end
    end
  end

  context "regression tests" do
    context "@node.parent.self_and_ancestors bug" do
      it "works correctly / is worked around" do
        # for details see Releaf::Content::Node::SinglenessValidator#base_relation_for_subtree
        @node1 = create_node(content_type: 'TextPage', locale: 'en')
        @node2 = create_node(content_type: 'TextPage', locale: 'lv')
        @node3 = create_node(content_type: 'TextPage', locale: 'ru')
        @node4 = create_node(content_type: 'TextPage', locale: 'sp')

        @node1_1 = create_node(content_type: 'DummySinglenessValidator2Controller',  parent: @node1)
        expect do
          @node1_2 = create_node(content_type: 'DummySinglenessValidator2Controller',  parent: @node2)
          @node1_3 = create_node(content_type: 'DummySinglenessValidator2Controller',  parent: @node3)
          @node1_4 = create_node(content_type: 'DummySinglenessValidator2Controller',  parent: @node4)
        end.to_not raise_error
      end
    end
  end

end
