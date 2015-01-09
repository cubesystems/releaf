require "spec_helper"

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
    context "when default controller is defined for given resource" do
      it "returns translated value" do
        allow(I18n).to receive(:t).with("releaf/i18n/database/translations", scope: "admin.menu_items").and_return("x")
        expect(subject.default_controller_content(resource_class.new(default_controller: "releaf/i18n_database/translations"))).to eq("x")
      end
    end

    context "when default controller is not defined for given resource" do
      it "returns dash" do
        expect(subject.default_controller_content(resource_class.new)).to eq("-")
      end
    end
  end
end
