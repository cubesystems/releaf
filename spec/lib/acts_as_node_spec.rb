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
    it "return all registerd classes" do
      expect(ActsAsNode.classes).to include("ContactFormController", "Contact")
    end
  end

  describe ActiveRecord::Acts::Node do
    context "when model acts as node" do
      it "have name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(Contact.to_s)).to be_true
      end
    end

    context "#node" do
      it "return node object" do
        contact = Contact.new
        contact.stub(:id).and_return(1)

        Releaf::Node.stub(:find_by_content_type_and_content_id).with(Contact.to_s, 1).and_return("node_obj")
        expect(contact.node).to eq("node_obj")
      end
    end

    context "#node_editable_fields" do
      it "return model columns" do
        contact = Contact.new
        Contact.stub(:column_names).and_return(%w(id created_at updated_at phone))
        expect(contact.node_editable_fields).to eq(["phone"])
      end
    end

    context ".nodes" do
      it "load tree nodes" do
        Releaf::Node.should_receive(:where).with(content_type: Contact.to_s)
        Contact.nodes
      end

      it "return array" do
        expect(Contact.nodes.class).to eq(ActiveRecord::Relation)
      end
    end
  end

  describe ActionController::Acts::Node do
    context "when controller acts as node" do
      it "have name included within ActsAsNode.classes" do
        expect(ActsAsNode.classes.include?(ContactFormController.to_s)).to be_true
      end
    end

    context "#node" do
      it "return nil" do
        expect(ContactFormController.new.node).to be_nil
      end
    end

    context "#node_editable_fields" do
      it "return empty array" do
        expect(ContactFormController.new.node_editable_fields).to eq([])
      end
    end

    context ".nodes" do
      it "load tree nodes" do
        Releaf::Node.should_receive(:where).with(content_type: ContactFormController.to_s)
        ContactFormController.nodes
      end

      it "return array" do
        expect(ContactFormController.nodes.class).to eq(ActiveRecord::Relation)
      end
    end
  end
end
