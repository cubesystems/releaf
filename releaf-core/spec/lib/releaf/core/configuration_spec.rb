require "spec_helper"

describe Releaf::Core::Configuration do
  describe "#configure" do
  end

  describe "#assets_resolver" do
  end

  describe "#access_control_module" do
  end

  describe "#initialize_defaults" do
  end

  describe "#initialize_locales" do
  end

  describe "#initialize_menu" do
  end

  describe "#initialize_components" do
  end

  describe "#normalize_components" do
  end

  describe "#normalized_additional_controllers" do
  end

  describe "#initialize_controllers" do
  end

  describe "#build_controller_list" do
  end

  describe "#normalize_controller_item" do
  end

  describe "#normalize_menu_item" do
  end

  describe "#default_values" do
    it "returns default configuration key, value hash" do
      result = {
        menu: [],
        devise_for: 'releaf/permissions/user',
        additional_controllers: [],
        controller_list: {},
        components: [],
        assets_resolver_class_name:  'Releaf::Core::AssetsResolver',
        layout_builder_class_name: 'Releaf::Builders::Page::LayoutBuilder',
        access_control_module_class_name: 'Releaf::Permissions'
      }
      expect(subject.default_values).to eq(result)
    end
  end
end


