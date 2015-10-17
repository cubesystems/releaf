require "rails_helper"

class ContactFormController < ActionController::Base
  acts_as_node
end

describe ActsAsNode do
  before do
    Book.acts_as_node
  end

  describe ".classes" do
    it "returns all registerd classes" do
      expect(ActsAsNode.classes).to include("ContactFormController", "Book")
    end
  end

  describe ".acts_as_node" do
    it "have configuration options for params and fields available through acts_as_node_configuration class method" do
      expect(Book.acts_as_node_configuration).to eq(params: nil, fields: nil)

      Book.acts_as_node params: ["x"], fields: ["a"]
      expect(Book.acts_as_node_configuration).to eq(params: ["x"], fields: ["a"])
    end

    it "has hard typed configuration options" do
      expect{ Book.acts_as_node xxxx: ["x"] }.to raise_error(ArgumentError, "unknown keyword: xxxx")
    end
  end

  describe ActiveRecord::Acts::Node do
    context "when model acts as node" do
      it "has name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(Book.to_s)).to be true
      end
    end

    describe "#node" do
      it "returns corresponding node object" do
        allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
        node = create(:node, content_type: "Book", content_attributes: {title: "xx"})
        expect(Book.last.node).to eq(node)
      end
    end

    context ".acts_as_node_params" do
      before do
        allow_any_instance_of(Releaf::Core::ResourceParams).to receive(:values).and_return(["a", "b"])
      end

      context "when `params` configuration is nil" do
        it "returns model params with `id` param" do
          allow(Book).to receive(:acts_as_node_configuration).and_return(params: nil)
          expect(Releaf::Core::ResourceParams).to receive(:new).with(Book).and_call_original
          expect(Book.acts_as_node_params).to eq(["a", "b", :id])
        end
      end

      context "when `params` configuration is not nil" do
        it "returns configuration values with `id` param" do
          allow(Book).to receive(:acts_as_node_configuration).and_return(params: ["c", "d"])
          expect(Book.acts_as_node_params).to eq(["c", "d", :id])
        end
      end
    end

    context ".acts_as_node_fields" do
      before do
        allow_any_instance_of(Releaf::Core::ResourceFields).to receive(:values).and_return(["a", "b"])
      end

      context "when `fields` configuration is nil" do
        it "returns model fields" do
          allow(Book).to receive(:acts_as_node_configuration).and_return(fields: nil)
          expect(Releaf::Core::ResourceFields).to receive(:new).with(Book).and_call_original
          expect(Book.acts_as_node_fields).to eq(["a", "b"])
        end
      end

      context "when `fields` configuration is not nil" do
        it "returns configuration values" do
          allow(Book).to receive(:acts_as_node_configuration).and_return(fields: ["c", "d"])
          expect(Book.acts_as_node_fields).to eq(["c", "d"])
        end
      end
    end

    context ".nodes" do
      it "loads tree nodes" do
        expect(Node).to receive(:where).with(content_type: Book.name)
        Book.nodes
      end

      it "returns relation" do
        expect(Book.nodes.class).to eq(Node::ActiveRecord_Relation)
      end
    end
  end

  describe ActionController::Acts::Node do
    context "when controller acts as node" do
      it "has name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(ContactFormController.to_s)).to be true
      end
    end

    context ".nodes" do
      it "loads tree nodes" do
        expect(Node).to receive(:where).with(content_type: ContactFormController.name)
        ContactFormController.nodes
      end

      it "returns array" do
        expect(ContactFormController.nodes.class).to eq(Node::ActiveRecord_Relation)
      end
    end
  end
end
