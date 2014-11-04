require "spec_helper"

describe Releaf::I18nDatabase::TranslationTableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::I18nDatabase::Translation }
  let(:subject){ described_class.new([], resource_class, template, {}) }

  describe "#column_names" do
    it "returns key and Releaf.all_locales column names array" do
      expect(subject.column_names).to eq([:key, "en", "lv"])
    end
  end

  describe "#locale_value" do
    it "returns localized value for given resource and column(locale)" do
      resource = resource_class.new
      allow(resource).to receive(:locale_value).with(:en).and_return("en value")
      expect(subject.locale_value(resource, :en)).to eq("en value")
    end
  end

  describe "#cell_format_method" do
    before do
      allow(Releaf).to receive(:all_locales).and_return([:de, :ze])
    end

    context "when given column name exists within Releaf.all_locales" do
      it "returns :locale_value" do
        expect(subject.cell_format_method(:de)).to eq(:locale_value)
        expect(subject.cell_format_method(:ze)).to eq(:locale_value)
      end
    end

    context "when given column name does not  exists within Releaf.all_locales" do
      it "return super" do
        expect(subject.cell_format_method(:en)).to eq(:format_string_content)
      end
    end
  end
end
