require 'spec_helper'

describe Releaf::Permissions::Roles::FormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Releaf::Permissions::Role.new }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#render_default_controller" do
    it "pass localized controller options to releaf item field" do
      allow(Releaf).to receive(:available_controllers).and_return(["releaf/i18n_database/translations", "releaf/content/nodes"])
      translated_controllers = {"Releaf/i18n database/translations"=>"releaf/i18n_database/translations", "Releaf/content/nodes"=>"releaf/content/nodes"}

      allow(subject).to receive(:releaf_item_field).with(:default_controller, options: {select_options: translated_controllers}).and_return("x")
      expect(subject.render_default_controller).to eq("x")
    end
  end

  describe "#render_permissions" do
    it "returns associated set field" do
      options = {association: {items: "x", field: :permission}}
      allow(subject).to receive(:permission_items).and_return("x")
      allow(subject).to receive(:releaf_associated_set_field).with(:permissions, options: options).and_return("y")
      expect(subject.render_permissions).to eq("y")
    end
  end

  describe "#permission_items" do
    it "returns scoped and translated controller values" do
      allow(Releaf).to receive(:available_controllers).and_return(["releaf/content/nodes", "admin/chapters"])
      allow(subject).to receive(:t).with("releaf/content/nodes", scope: "admin.controllers").and_return("controller 1")
      allow(subject).to receive(:t).with("admin/chapters", scope: "admin.controllers").and_return("controller 2")
      expect(subject.permission_items).to eq("controller.releaf/content/nodes" => "controller 1", "controller.admin/chapters" => "controller 2")
    end
  end
end
