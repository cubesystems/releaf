# encoding: UTF-8

require "spec_helper"

describe Releaf::Node do
  let(:node) { Releaf::Node.new }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:content_type) }
  end

  describe "after save" do
    it "sets node update to current time" do
      Settings['nodes.updated_at'] = Time.now
      time_now = Time.parse("2009-02-23 21:00:00 UTC")
      Time.stub(:now).and_return(time_now)

      expect{ FactoryGirl.create(:node) }.to change{ Settings['nodes.updated_at'] }.to(time_now)
    end
  end

  describe "#to_s" do
    it "returns name" do
      expect(node.to_s).to eq(node.name)
    end
  end

  describe "#destroy" do
    before do
      @node = FactoryGirl.create(:node)
    end

    it "sets node update to current time" do
      @time_now = Time.parse("2009-02-23 21:00:00 UTC")
      Time.stub(:now).and_return(@time_now)
      expect{ @node.destroy }.to change{ Settings['nodes.updated_at'] }.to(@time_now)
    end
  end

  describe "#copy_to_node" do
    before do
      @text_node = FactoryGirl.create(:text_node)
      @text_node_2 = FactoryGirl.create(:text_node)
      @text_node_3 = FactoryGirl.create(:text_node, :parent_id => @text_node.id )
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
      @text_node_3 = FactoryGirl.create(:text_node, :parent_id => @text_node_2.id)
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
    let(:node) { FactoryGirl.create(:text_node, :parent_id => root.id, :name => "Test node") }
    let(:sibling) { FactoryGirl.create(:text_node, :parent_id => root.id, :name => "Test node(1)") }

    context "when node don't have sibling/s with same name" do
      it "does not changes node's name" do
        new_node = Releaf::Node.new(:name => "another name", :parent_id => root.id)
        expect{ new_node.maintain_name }.to_not change{new_node.name}
      end
    end

    context "when node have sibling/s with same name" do
      it "changes node's name" do
        new_node = Releaf::Node.new(:name => node.name, :parent_id => root.id)
        expect{ new_node.maintain_name }.to change{new_node.name}.from(node.name).to("#{node.name}(1)")
      end

      it "increments node's name number" do
        sibling
        new_node = Releaf::Node.new(:name => node.name, :parent_id => root.id)
        expect{ new_node.maintain_name }.to change{new_node.name}.from(node.name).to("#{node.name}(2)")
      end
    end
  end

  describe ".updated_at" do
    it "returns last node update" do
      time_now = Time.now
      Time.stub(:now).and_return(time_now)
      FactoryGirl.create(:node)

      expect(Releaf::Node.updated_at).to eq(time_now)
    end
  end
end
