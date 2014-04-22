require "spec_helper"

class ContactFormController < ActionController::Base
  acts_as_node
end

describe ActsAsNode do
  before do
    Book.acts_as_node permit_attributes: [:text_html]
  end

  describe ".classes" do
    it "returns all registerd classes" do
      expect(ActsAsNode.classes).to include("ContactFormController", "Book")
    end
  end

  describe ".acts_as_node" do
    it "have configuration options available through acts_as_node_configuration class method" do
      expect(Book.acts_as_node_configuration).to eq({validators: [], permit_attributes: [:text_html]})
    end
  end

  describe ActiveRecord::Acts::Node do
    context "when model acts as node" do
      it "has name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(Book.to_s)).to be_true
      end
    end

    describe "#node" do
      it "returns corresponding node object" do
        node = FactoryGirl.create(:node, content_type: "Book", content_attributes: {title: "xx"})
        expect(Book.last.node).to eq(node)
      end
    end

    context "#node_editable_fields" do
      it "returns model columns" do
        expect(Book.new.node_editable_fields).to eq(["title", "year", "author_id", "genre", "summary_html", "active", "published_at", "price", "cover_image_uid"])
      end
    end

    context ".nodes" do
      it "loads tree nodes" do
        Releaf::Node.should_receive(:where).with(content_type: Book.to_s)
        Book.nodes
      end

      it "returns relation" do
        expect(Book.nodes.class).to eq(ActiveRecord::Relation::ActiveRecord_Relation_Node)
      end
    end
  end

  describe ActionController::Acts::Node do
    context "when controller acts as node" do
      it "has name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(ContactFormController.to_s)).to be_true
      end
    end

    context "#node_editable_fields" do
      it "returns empty array" do
        expect(ContactFormController.new.node_editable_fields).to eq([])
      end
    end

    context ".nodes" do
      it "loads tree nodes" do
        Releaf::Node.should_receive(:where).with(content_type: ContactFormController.to_s)
        ContactFormController.nodes
      end

      it "returns array" do
        expect(ContactFormController.nodes.class).to eq(ActiveRecord::Relation::ActiveRecord_Relation_Node)
      end
    end
  end
end
