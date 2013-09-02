require "spec_helper"

class ContactFormController < ActionController::Base
  acts_as_node
end

class Contact < ActiveRecord::Base
  acts_as_node
  def self.columns
    @columns ||= [];
  end

  #def self.column_names
    #@column_names ||= %w(id created_at updated_at phone)
  #end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
      sql_type.to_s, null)
  end
end

describe ActsAsNode do
  describe ".classes" do
    it "returns all registerd classes" do
      expect(ActsAsNode.classes).to include("ContactFormController", "Contact")
    end
  end

  describe ActiveRecord::Acts::Node do
    context "when model acts as node" do
      it "has name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(Contact.to_s)).to be_true
      end
    end

    context "#node_editable_fields" do
      it "returns model columns" do
        contact = Contact.new
        Contact.stub(:column_names).and_return(%w(id created_at updated_at phone))
        expect(contact.node_editable_fields).to eq(["phone"])
      end
    end

    context ".nodes" do
      it "loads tree nodes" do
        Releaf::Node.should_receive(:where).with(content_type: Contact.to_s)
        Contact.nodes
      end

      it "returns array" do
        expect(Contact.nodes.class).to eq(ActiveRecord::Relation)
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
        expect(ContactFormController.nodes.class).to eq(ActiveRecord::Relation)
      end
    end
  end
end
