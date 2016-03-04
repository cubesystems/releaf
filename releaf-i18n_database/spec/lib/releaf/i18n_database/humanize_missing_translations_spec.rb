require "rails_helper"

describe Releaf::I18nDatabase::HumanizeMissingTranslations do
  describe ".call" do
    context "when key is present and exception is I18n::MissingTranslation" do
      it "humanizes missing translations" do
        expect(I18n.t("some.missing translation")).to eq("Missing translation")
      end
    end

    context "when key is not present and exception is I18n::MissingTranslation" do
      it "does not intercept it" do
        expect(I18n.t(nil)).to eq("translation missing: en.no key")
      end
    end

    context "when exception is not I18n::MissingTranslation" do
      it "does not intercept it" do
        allow(I18n::Backend::Transliterator).to receive(:get).and_raise(I18n::ArgumentError)
        expect{I18n.transliterate("error?")}.to raise_error(I18n::ArgumentError)
      end
    end
  end
end
