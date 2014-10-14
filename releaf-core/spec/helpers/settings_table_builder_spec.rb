require "spec_helper"

describe Releaf::SettingsTableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::Settings }
  let(:subject){ described_class.new([], resource_class, template, {}) }

  describe "#column_names" do
    it "returns var, value and updated_at as column names array" do
      expect(subject.column_names).to eq([:var, :value, :updated_at])
    end
  end
end
