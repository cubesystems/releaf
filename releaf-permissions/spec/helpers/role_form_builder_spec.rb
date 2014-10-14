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
    it "returns checkbox output for all releaf available controllers" do
      allow(Releaf).to receive(:available_controllers).and_return(["a", "b"])
      allow(subject).to receive(:permission_field).with("a").and_return("aa")
      allow(subject).to receive(:permission_field).with("b").and_return("bb")
      expect(subject.render_permissions).to eq("aabb")
    end
  end

  describe "#permission_field", pending: true do
    it "returns permission checkbox for given controller" do
      expect(subject.permission_field("releaf/i18n_database/translations")).to eq("x")
    end
  end
end
