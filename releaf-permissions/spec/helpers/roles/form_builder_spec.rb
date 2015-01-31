require "spec_helper"

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
    it "returns checkbox group" do
      options = {
        association: {
          values: ["releaf/content/nodes", "admin/books", "admin/authors", "releaf/permissions/users",
                   "releaf/permissions/roles", "releaf/core/settings", "releaf/i18n_database/translations",
                   "admin/chapters", "releaf/permissions/profile"],
          field: :permission,
          translation_scope: "admin.menu_items"
        }
      }
      allow(subject).to receive(:releaf_checkbox_group_field).with(:permissions, options: options).and_return("y")
      expect(subject.render_permissions).to eq("y")
    end
  end
end
