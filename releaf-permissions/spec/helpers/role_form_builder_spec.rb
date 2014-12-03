require "spec_helper"

describe Releaf::Permissions::RoleFormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Releaf::Permissions::Role.new }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#field_names" do
    it "returns name and default_controller as field names array" do
      expect(subject.field_names).to eq(%w(name default_controller permissions))
    end
  end

  describe "#render_default_controller" do
    it "pass localized controller options to releaf item field" do
      allow(Releaf).to receive(:available_controllers).and_return(["releaf/i18n_database/translations", "releaf/content/nodes"])
      translated_controllers = {"Releaf/i18n database/translations"=>"releaf/i18n_database/translations", "Releaf/content/nodes"=>"releaf/content/nodes"}

      allow(subject).to receive(:releaf_item_field).with(:default_controller, options: {select_options: translated_controllers}).and_return("x")
      expect(subject.render_default_controller).to eq("x")
    end
  end

  describe "#render_permissions" do
    it "returns checkbox group" do
      allow(subject).to receive(:permissions_items).and_return("x")
      allow(subject).to receive(:releaf_checkbox_group).with(:permissions, options: {items: "x"}).and_return("y")
      expect(subject.render_permissions).to eq("y")
    end
  end

  describe "#permissions_items" do
    it "returns array with items for #releaf_checkbox_group options[:items]" do
      allow(Releaf).to receive(:available_controllers).and_return(["releaf/i18n_database/translations", "releaf/content/nodes"])
      allow(subject).to receive(:t).with("releaf/i18n_database/translations", scope: "admin.menu_items").and_return("aa")
      allow(subject).to receive(:t).with("releaf/content/nodes", scope: "admin.menu_items").and_return("bb")
      items = [
        {value: "releaf/i18n_database/translations", label: "aa"},
        {value: "releaf/content/nodes", label: "bb"}
      ]

      expect(subject.permissions_items).to eq(items)
    end
  end
end
