require "spec_helper"

describe Releaf::Core::Settings::TableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::Settings }
  let(:subject){ described_class.new([], resource_class, template, {}) }

  describe "#column_names" do
    it "returns var, value and updated_at as column names array" do
      expect(subject.column_names).to eq([:var, :value, :updated_at])
    end
  end

  describe "#value_content" do
    it "return resource value casted to string" do
      resource = Releaf::Settings.new(value: Date.parse("2012-01-01"))
      expect(subject.value_content(resource)).to eq("2012-01-01")
    end
  end
end
