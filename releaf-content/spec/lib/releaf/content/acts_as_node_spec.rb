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

    context ".acts_as_node_params" do
      before do
        allow_any_instance_of(Releaf::ResourceParams).to receive(:values).and_return(["a", "b"])
      end

      context "when `params` configuration is nil" do
        it "returns model params with `id` param" do
          allow(Book).to receive(:acts_as_node_configuration).and_return(params: nil)
          expect(Releaf::ResourceParams).to receive(:new).with(Book).and_call_original
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
        allow_any_instance_of(Releaf::ResourceFields).to receive(:values).and_return(["a", "b"])
      end

      context "when `fields` configuration is nil" do
        it "returns model fields" do
          allow(Book).to receive(:acts_as_node_configuration).and_return(fields: nil)
          expect(Releaf::ResourceFields).to receive(:new).with(Book).and_call_original
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

  end

  describe ActionController::Acts::Node do
    context "when controller acts as node" do
      it "has name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(ContactFormController.to_s)).to be true
      end
    end

  end
end
