# encoding: UTF-8

require "spec_helper"

describe Releaf::Node do
  class DummyNodeTestValidation < ActiveModel::Validator
    def validate record
    end
  end

  class DummyNodeTestModel < ActiveRecord::Base
    acts_as_node validators: [DummyNodeTestValidation]
  end

  class DummyNodeTestController < ActionController::Base
    acts_as_node validators: [DummyNodeTestValidation]
  end

  let(:node) { Releaf::Node.new }

  it { should serialize(:data).as(Hash) }
  it { should accept_nested_attributes_for(:content) }
  it { should belong_to(:content) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:content_type) }
    it { should validate_uniqueness_of(:slug).scoped_to(:parent_id) }
    it { should ensure_length_of(:name).is_at_most(255) }
    it { should ensure_length_of(:slug).is_at_most(255) }

    context "when content is model" do
      context "when user suplied custom validations via acts_as_node" do
        it "runs custom validations during validation" do
          subject.content_type = 'DummyNodeTestModel'
          expect_any_instance_of(DummyNodeTestValidation).to receive(:validate).with(subject)
          subject.valid?
        end
      end
    end

    context "when content is controller" do
      context "when user suplied custom validations via acts_as_node" do
        it "runs custom validations during validation" do
          subject.content_type = 'DummyNodeTestController'
          expect_any_instance_of(DummyNodeTestValidation).to receive(:validate).with(subject)
          subject.valid?
        end
      end
    end
  end

  describe "after save" do
    it "sets node update to current time" do
      Settings['nodes.updated_at'] = Time.now
      time_now = Time.parse("2009-02-23 21:00:00 UTC")
      Time.stub(:now).and_return(time_now)

      expect{ FactoryGirl.create(:node) }.to change{ Settings['nodes.updated_at'] }.to(time_now)
    end
  end

  describe "#content_class" do
    context 'when #content_type is nil' do
      it 'returns nil' do
        subject.content_type = nil
        expect( subject.content_class ).to be_nil
      end
    end

    context "when #content_type is blank string" do
      it 'returns nil' do
        subject.content_type = ""
        expect( subject.content_class ).to be_nil
      end
    end

    context "when #content_type is not blank" do
      it "constantizes it" do
        subject.content_type = "Releaf::Node"
        expect( subject.content_class ).to eq Releaf::Node
      end
    end
  end

  describe "#to_s" do
    it "returns name" do
      expect(node.to_s).to eq(node.name)
    end
  end

  describe "#locale" do
    before do
      root = FactoryGirl.create(:node, locale: "lv")
      parent = FactoryGirl.create(:node, locale: nil, parent_id: root.id)
      @child1 = FactoryGirl.create(:node, locale: nil, parent_id: parent.id)
      @child2 = FactoryGirl.create(:node, locale: nil, parent_id: parent.id, locale: "en")
    end

    context "when node locale is nil" do
      it "uses closest parent locale" do
        expect(@child1.locale).to eq("lv")
      end
    end

    context "when object node have locale" do
      it "uses closest parent locale" do
        expect(@child2.locale).to eq("en")
      end
    end
  end

  describe "#destroy" do
    context "when content object class exists" do
      it "deletes record" do
        node = FactoryGirl.create(:node, content_type: 'DummyNodeTestModel')
        expect { node.destroy }.to change { Releaf::Node.count }.by(-1)
      end
    end

    def stub_content_class &block
      Releaf::Node.any_instance.stub(:content_class)
      yield
      Releaf::Node.any_instance.unstub(:content_class)
    end

    context "when content object class doesn't exists" do
      it "deletes record" do
        stub_content_class do
          @node = FactoryGirl.create(:node, content_type: 'NonExistingTestModel', content_id: 1)
        end
        expect { @node.destroy }.to change { Releaf::Node.count }.by(-1)
      end

      it "retries to delete record only once" do
        stub_content_class do
          @node = FactoryGirl.create(:node, content_type: 'NonExistingTestModel', content_id: 1)
        end
        @node.stub(:content_type=)
        @node.stub(:content_id=)

        expect { @node.destroy }.to raise_error NameError
        expect( Releaf::Node.count ).to eq 1
      end
    end

    it "sets node update to current time" do
      node = FactoryGirl.create(:node)
      time_now = Time.parse("2009-02-23 21:00:00 UTC")
      Time.stub(:now).and_return(time_now)
      expect{ node.destroy }.to change{ Settings['nodes.updated_at'] }.to(time_now)
    end
  end

  describe "#copy_to_node" do
    before do
      @text_node = FactoryGirl.create(:text_node)
      @text_node_2 = FactoryGirl.create(:text_node)
      @text_node_3 = FactoryGirl.create(:text_node, parent_id: @text_node.id )
    end

    context "with corect parent_id" do
      it "creates new node" do
        expect{ @text_node_2.copy_to_node(@text_node.id) }.to change{ Releaf::Node.count }.by(1)
      end
    end

    context "when node have children" do
      it "creates multiple new nodes" do
        @text_node_2.copy_to_node(@text_node.id)
        expect{ @text_node.copy_to_node(@text_node_2.id) }.to change{ Releaf::Node.count }.by( @text_node.children.size + 1 )
      end
    end

    context "when parent_id is nil" do
      it "creates new node" do
        expect{ @text_node_3.copy_to_node(nil) }.to change{ Releaf::Node.count }.by(1)
      end
    end

    context "with nonexistent parent_id" do
      it "doesn't create new node" do
        expect{ @text_node_2.copy_to_node(99991) }.not_to change{ Releaf::Node.count }
      end
    end

    context "with same parent_id as node.id" do
      it "doesn't create new node" do
        expect{ @text_node.copy_to_node(@text_node.id) }.not_to change{ Releaf::Node.count }
      end
    end

    context "when passing string as argument" do
      it "doesn't create new node" do
        expect{ @text_node.copy_to_node("some_id") }.not_to change{ Releaf::Node.count }
      end
    end
  end

  describe "#move_to_node" do
    before do
      @text_node = FactoryGirl.create(:text_node)
      @text_node_2 = FactoryGirl.create(:text_node)
      @text_node_3 = FactoryGirl.create(:text_node, parent_id: @text_node_2.id)
    end

    context "when moving existing node to other nodes child's position" do
      it "changes parent_id" do
        expect{ @text_node_3.move_to_node(@text_node.id) }.to change{ Releaf::Node.find_by_id(@text_node_3.id).parent_id }.from(@text_node_2.id).to(@text_node.id)
      end
    end

    context "when moving to self child's position" do
      it "doesn't change parent_id" do
        expect{ @text_node_3.move_to_node(@text_node_3.id) }.not_to change{ Releaf::Node.find_by_id(@text_node_3.id).parent_id }
      end
    end

    context "when passing nil as target node" do
      it "doesn't change parent_id" do
        expect{ @text_node_3.move_to_node(nil) }.to change{ Releaf::Node.find_by_id(@text_node_3.id).parent_id }
      end
    end

    context "when passing nonexistent target node's id" do
      it "doesn't change parent_id" do
        expect{ @text_node_3.move_to_node(998123) }.not_to change{ Releaf::Node.find_by_id(@text_node_3.id).parent_id }
      end
    end

    context "when passing string as argument" do
      it "doesn't change parent_id" do
        expect{ @text_node_3.move_to_node("test") }.not_to change{ Releaf::Node.find_by_id(@text_node_3.id).parent_id }
      end
    end
  end

  describe "#maintain_name" do
    let(:root) { FactoryGirl.create(:text_node) }
    let(:node) { FactoryGirl.create(:text_node, parent_id: root.id, name:  "Test node") }
    let(:sibling) { FactoryGirl.create(:text_node, parent_id: root.id, name:  "Test node(1)") }

    context "when node don't have sibling/s with same name" do
      it "does not changes node's name" do
        new_node = Releaf::Node.new(name:  "another name", parent_id: root.id)
        expect{ new_node.maintain_name }.to_not change{new_node.name}
      end
    end

    context "when node have sibling/s with same name" do
      it "changes node's name" do
        new_node = Releaf::Node.new(name:  node.name, parent_id: root.id)
        expect{ new_node.maintain_name }.to change{new_node.name}.from(node.name).to("#{node.name}(1)")
      end

      it "increments node's name number" do
        sibling
        new_node = Releaf::Node.new(name:  node.name, parent_id: root.id)
        expect{ new_node.maintain_name }.to change{new_node.name}.from(node.name).to("#{node.name}(2)")
      end
    end
  end

  describe ".updated_at" do
    it "returns last node update" do
      Timecop.freeze
      FactoryGirl.create(:node)
      expect(Releaf::Node.updated_at.to_i).to eq(Time.now.to_i)
    end
  end

  describe "#available?" do
    let(:root) { FactoryGirl.create(:text_node, active: true) }
    let(:subject_ancestor) { FactoryGirl.create(:text_node, parent_id: root.id, name:  "Test node", active: true) }
    let(:subject) { FactoryGirl.create(:text_node, parent_id: subject_ancestor.id, name:  "Test node", active: true) }

    context "when object and all its ancestors are active" do
      it "returns true" do
        expect(subject.available?).to be_true
      end
    end

    context "when object itself is not active" do
      it "returns false" do
        subject.update_attribute(:active, false)
        expect(subject.available?).to be_false
      end
    end

    context "when any of object ancestors are not active" do
      it "returns false" do
        subject_ancestor.update_attribute(:active, false)
        expect(subject.available?).to be_false
      end
    end
  end

  describe "#content_class" do
    context "when #content_type is valid class name" do
      it "returns constantizes content_class" do
        subject.content_type = "String"
        expect( subject.content_class ).to eq String
      end
    end

    context "when #content_type is blank" do
      it "returns nil" do
        subject.content_type = ""
        expect( subject.content_class ).to be_nil
      end
    end
  end

  describe "#custom_validators" do
    context "when content_type is valid model name" do
      it "returns user suplied validators via acts_as_node" do
        subject.content_type = 'DummyNodeTestModel'
        expect( subject.custom_validators ).to match_array [DummyNodeTestValidation]
      end
    end

    context "when content_type is blank" do
      it "returns nil" do
        subject.content_type = ''
        expect( subject.custom_validators ).to be_nil
      end
    end
  end

  describe "common_fields" do
    before do
      stub_const('Releaf::Node::COMMON_FIELDS_SCHEMA_FILENAME', File.expand_path('../fixtures/common_fields.yml', __dir__))

      text1 = FactoryGirl.create(:text)
      text2 = FactoryGirl.create(:text)
      @nodes = []
      @nodes << FactoryGirl.create(:node, name: "RootNode", content: text1)
      @nodes << FactoryGirl.create(:node, name: "subNode", content: text2, parent_id: @nodes[0].id)
      @nodes << FactoryGirl.create(:node, name: 'contacts', content_type: 'ContactsController')

    end

    describe "#common_field_names" do
      it "is returns names of available common fields" do
        expect( @nodes[0].common_field_names ).to match_array []
        expect( @nodes[1].common_field_names ).to match_array %w[data_meta_copyright]
        expect( @nodes[2].common_field_names ).to match_array %w[data_meta_description data_other_attribute]
      end
    end

    describe "dynamic methods" do
      it "responds to valid common fields setters and getters" do
        expect( @nodes[0] ).to_not  respond_to "data_meta_description"
        expect( @nodes[0] ).to_not  respond_to "data_meta_description="
        expect( @nodes[0] ).to_not  respond_to "data_meta_copyright"
        expect( @nodes[0] ).to_not  respond_to "data_meta_copyright="
        expect( @nodes[0] ).to_not  respond_to "data_other_attribute"
        expect( @nodes[0] ).to_not  respond_to "data_other_attribute="

        expect( @nodes[1] ).to_not  respond_to "data_meta_description"
        expect( @nodes[1] ).to_not  respond_to "data_meta_description="
        expect( @nodes[1] ).to      respond_to "data_meta_copyright"
        expect( @nodes[1] ).to      respond_to "data_meta_copyright="
        expect( @nodes[1] ).to_not  respond_to "data_other_attribute"
        expect( @nodes[1] ).to_not  respond_to "data_other_attribute="

        expect( @nodes[2] ).to      respond_to "data_meta_description"
        expect( @nodes[2] ).to      respond_to "data_meta_description="
        expect( @nodes[2] ).to_not  respond_to "data_meta_copyright"
        expect( @nodes[2] ).to_not  respond_to "data_meta_copyright="
        expect( @nodes[2] ).to      respond_to "data_other_attribute"
        expect( @nodes[2] ).to      respond_to "data_other_attribute="
      end
    end

    describe "dynamic getter" do
      context "when value wasn't saved" do
        it "returns default value" do
          expect( @nodes[2].data_meta_description ).to eq 'common stuff'
          expect( @nodes[2].data_other_attribute ).to be_nil
        end
      end

      context "when value was saved" do
        it "returns saved value" do
          @nodes[2].stub(:data).and_return({'meta_description' => 'test', 'other_attribute' => 'asd'})
          expect( @nodes[2].data_meta_description ).to eq 'test'
          expect( @nodes[2].data_other_attribute ).to eq 'asd'
        end
      end
    end

    describe "dynamic setter" do
      it "stores value in #data attribute as has, using attribute name (without prefix) as key" do
        data_store = double('Hash')

        expect( @nodes[2] ).to receive(:data).and_return(data_store)
        expect( data_store ).to receive(:[]=).with('other_attribute', 'test value')

        @nodes[2].data_other_attribute = 'test value'

      end

      it "changes getter return value" do
        expect { @nodes[2].data_other_attribute = 'test' }.to change { @nodes[2].data_other_attribute }.from(nil).to('test')
      end

      it "stores value in db record" do
        @nodes[2].data_other_attribute = 'la la la'
        @nodes[2].save!

        expect( Releaf::Node.find(@nodes[2].id).data_other_attribute ).to eq 'la la la'
      end
    end

  end
end
