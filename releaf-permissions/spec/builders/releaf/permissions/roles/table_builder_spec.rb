require "rails_helper"

describe Releaf::Permissions::Roles::TableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::Permissions::Role }
  let(:subject){ described_class.new([], resource_class, template, {}) }

  describe "#column_names" do
    it "returns name and default_controller as column names array" do
      expect(subject.column_names).to eq([:name, :default_controller])
    end
  end

  describe "#default_controller_content" do
    context "when given resource default controller definition exists" do
      it "returns localized controller name from definitioned followed by application name" do
        definition = Releaf::ControllerDefinition.new("xx")
        allow(definition).to receive(:localized_name).and_return("x")
        allow(Releaf::ControllerDefinition).to receive(:for).with("contr").and_return(definition)
        expect(subject.default_controller_content(resource_class.new(default_controller: "contr"))).to eq("x")
      end
    end

    context "when given resource default controller definition does not exist" do
      it "returns dash" do
        definition = Releaf::ControllerDefinition.new("xx")
        allow(definition).to receive(:localized_name).and_return("x")
        allow(Releaf::ControllerDefinition).to receive(:for).with("contr").and_return(nil)
        expect(subject.default_controller_content(resource_class.new(default_controller: "contr"))).to eq("-")
      end
    end

    context "when default controller is not defined for given resource" do
      it "returns dash" do
        expect(Releaf::ControllerDefinition).to_not receive(:for)
        expect(subject.default_controller_content(resource_class.new)).to eq("-")
      end
    end
  end
end
