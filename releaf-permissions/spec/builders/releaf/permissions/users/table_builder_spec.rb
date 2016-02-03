require "rails_helper"

describe Releaf::Permissions::Users::TableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::Permissions::User }
  let(:subject){ described_class.new([], resource_class, template, {}) }

  describe "#column_names" do
    it "returns name, surname, role, email and locale as column names array" do
      expect(subject.column_names).to eq([:name, :surname, :role, :email, :locale])
    end
  end

  describe "#locale_content" do
    it "returns translated locale" do
      allow(subject).to receive(:translate_locale).with("de").and_return("deutch")
      expect(subject.locale_content(resource_class.new(locale: "de"))).to eq("deutch")
    end
  end
end
