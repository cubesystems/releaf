require "rails_helper"

describe Releaf::Permissions::Page::MenuBuilder, type: :class do
  class MenuBuilderTestHelper < ActionView::Base
    include FontAwesome::Rails::IconHelper
  end

  let(:controller){ Releaf::ActionController.new }
  let(:template){ MenuBuilderTestHelper.new }
  let(:group_item){ Releaf::ControllerGroupDefinition.new(name: "x", items: []) }
  let(:controller_item){ Releaf::ControllerDefinition.new(name: "y", controller: "_controller_") }
  subject { described_class.new(template) }

  before do
    allow(template).to receive(:controller).and_return(controller)
  end

  it "inherits `Releaf::Builders::Page::MenuBuilder`" do
    expect(described_class.ancestors).to include(Releaf::Builders::Page::MenuBuilder)
  end

  describe "#menu_item" do
    before do
      allow(subject).to receive(:item_attributes).and_return({})
      allow(subject).to receive(:menu_item_group).and_return("_content_")
    end

    context "when item is permitted" do
      it "returns parent method content" do
        allow(subject).to receive(:menu_item_permitted?).with(group_item).and_return(true)
        expect(subject.menu_item(group_item)).to eq("<li>_content_</li>")
      end
    end

    context "when item is not permitted" do
      it "returns nil" do
        allow(subject).to receive(:menu_item_permitted?).with(group_item).and_return(false)
        expect(subject.menu_item(group_item)).to be nil
      end
    end
  end

  describe "#menu_item_permitted?" do
    context "when item is instance of `Releaf::ControllerGroupDefinition`" do
      before do
        allow(group_item).to receive(:controllers).and_return([
          Releaf::ControllerDefinition.new(name: "a1", controller: "c1"),
          Releaf::ControllerDefinition.new(name: "a2", controller: "c2"),
          Releaf::ControllerDefinition.new(name: "a3", controller: "c3"),
        ])
      end

      context "when any of group item controller is allowed" do
        it "returns true" do
          allow(subject).to receive(:controller_permitted?).with("c1").and_return(false)
          allow(subject).to receive(:controller_permitted?).with("c2").and_return(true)
          expect(subject).to_not receive(:controller_permitted?).with("c3")
          expect(subject.menu_item_permitted?(group_item)).to be true
        end
      end

      context "when none of group item controller is allowed" do
        it "returns false" do
          allow(subject).to receive(:controller_permitted?).with("c1").and_return(false)
          allow(subject).to receive(:controller_permitted?).with("c2").and_return(false)
          allow(subject).to receive(:controller_permitted?).with("c3").and_return(false)
          expect(subject.menu_item_permitted?(group_item)).to be false
        end
      end
    end

    context "when item is instance of `Releaf::ControllerDefinition`" do
      context "when item controller is allowed" do
        it "returns true" do
          allow(subject).to receive(:controller_permitted?).with("_controller_").and_return(true)
          expect(subject.menu_item_permitted?(controller_item)).to be true
        end
      end

      context "when item controller is not allowed" do
        it "returns false" do
          allow(subject).to receive(:controller_permitted?).with("_controller_").and_return(false)
          expect(subject.menu_item_permitted?(controller_item)).to be false
        end
      end
    end
  end

  describe "#controller_permitted?" do
    it "returns access controller controller permission query result for given controller name" do
      user = Releaf::Permissions::User.new
      allow(controller).to receive(:user).and_return("x")
      access_control = Releaf::Permissions::AccessControl.new(user: user)
      allow(Releaf.application.config.permissions.access_control).to receive(:new).with(user: "x").and_return(access_control)
      allow(access_control).to receive(:controller_permitted?).with("kjasdasd").and_return("_true")

      expect(subject.controller_permitted?("kjasdasd")).to eq("_true")
    end
  end
end
