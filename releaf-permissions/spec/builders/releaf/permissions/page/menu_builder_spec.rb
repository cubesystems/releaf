require "rails_helper"

describe Releaf::Permissions::Page::MenuBuilder, type: :class do
  class MenuBuilderTestHelper < ActionView::Base
    include FontAwesome::Rails::IconHelper
  end

  let(:controller){ Releaf::BaseController.new }
  let(:template){ MenuBuilderTestHelper.new }
  subject { described_class.new(template) }

  before do
    allow(template).to receive(:controller).and_return(controller)
  end

  it "inherits `Releaf::Builders::Page::MenuBuilder`" do
    expect(described_class.ancestors).to include(Releaf::Builders::Page::MenuBuilder)
  end

  describe "#build_items" do
    it "filters only permitted controller items and item groups" do
      list = ["item1", "item2", "item3"]
      item_a = {items: ["a", "b"]}
      item_b = {controller: "controller_b"}
      item_c = {controller: "controller_c"}

      allow(subject).to receive(:build_item).with("item1").and_return(item_a)
      allow(subject).to receive(:build_item).with("item2").and_return(item_b)
      allow(subject).to receive(:build_item).with("item3").and_return(item_c)
      allow(subject).to receive(:controller_permitted?).with("controller_b").and_return(false)
      allow(subject).to receive(:controller_permitted?).with("controller_c").and_return(true)

      expect(subject.build_items(list)).to eq([item_a, item_c])
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
