require "rails_helper"

describe Releaf::I18nDatabase::Translations::TableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::I18nDatabase::I18nEntry }
  let(:subject){ described_class.new([], resource_class, template, {}) }

  before do
    allow(Releaf.application.config).to receive(:all_locales).and_return(["de", "ze"])
  end

  describe "#column_names" do
    it "returns key and Releaf.application.config column names array" do
      expect(subject.column_names).to eq([:key, "de", "ze"])
    end
  end

  describe "#head_cell_content" do
    context "when locale column given" do
      it "returns head cell content with translated locale" do
        allow(subject).to receive(:translate_locale).with("de").and_return("gegxxxeg")
        expect(subject.head_cell_content("de")).to eq('gegxxxeg')
      end
    end

    context "when non locale column given" do
      it "returns head cell content with translated locale" do
        expect(subject).to_not receive(:translate_locale)
        expect(subject.head_cell_content("lv")).to eq('Lv')
      end
    end
  end

  describe "#cell_content" do
    it "wraps content within span element" do
      resource = resource_class.new(key: "xx")
      expect(subject.cell_content(resource, :key, format_method: :format_string_content)).to eq("<span>xx</span>")
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
      allow(Releaf.application.config).to receive(:all_locales).and_return([:de, :ze])
    end

    context "when given column name exists within Releaf.application.config.all_locales" do
      it "returns :locale_value" do
        expect(subject.cell_format_method(:de)).to eq(:locale_value)
        expect(subject.cell_format_method(:ze)).to eq(:locale_value)
      end
    end

    context "when given column name does not  exists within Releaf.application.config.all_locales" do
      it "return super" do
        expect(subject.cell_format_method(:en)).to eq(:format_string_content)
      end
    end
  end
end
