require 'rails_helper'

describe Releaf::Permissions::Roles::FormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Releaf::Permissions::Role.new }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  before do
    allow(Releaf.application.config).to receive(:available_controllers)
      .and_return(["releaf/content/nodes", "admin/chapters"])

    definition_1 = Releaf::ControllerDefinition.new("xx")
    allow(definition_1).to receive(:localized_name).and_return("controller 1")
    allow(definition_1).to receive(:controller_name).and_return("admin/controller_1")

    definition_2 = Releaf::ControllerDefinition.new("xx")
    allow(definition_2).to receive(:localized_name).and_return("controller 2")
    allow(definition_2).to receive(:controller_name).and_return("admin/controller_2")

    allow(Releaf::ControllerDefinition).to receive(:for).with("releaf/content/nodes").and_return(definition_1)
    allow(Releaf::ControllerDefinition).to receive(:for).with("admin/chapters").and_return(definition_2)
  end

  describe "#render_default_controller" do
    it "pass localized controller options to releaf item field" do
      translated_controllers = {
        "controller 1" => "admin/controller_1",
        "controller 2" => "admin/controller_2"
      }

      allow(subject).to receive(:releaf_item_field)
        .with(:default_controller, options: {select_options: translated_controllers})
        .and_return("x")
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
      expect(subject.permission_items).to eq(
        "controller.admin/controller_1" => "controller 1",
        "controller.admin/controller_2" => "controller 2"
      )
    end
  end
end
