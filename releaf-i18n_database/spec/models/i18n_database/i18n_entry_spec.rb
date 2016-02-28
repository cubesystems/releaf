require "rails_helper"

describe Releaf::I18nDatabase::I18nEntry do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_length_of(:key).is_at_most(255) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to have_many(:i18n_entry_translation).dependent(:destroy) }
  it { is_expected.to accept_nested_attributes_for(:i18n_entry_translation).allow_destroy(true) }

  describe "#locale_value" do
    it "returns translated value for given locale" do
      subject.i18n_entry_translation.build(text: 'apple', locale: "en")
      subject.i18n_entry_translation.build(text: 'apfel', locale: "de")

      expect(subject.locale_value("en")).to eq("apple")
      expect(subject.locale_value(:de)).to eq("apfel")
      expect(subject.locale_value("lt")).to be nil
    end
  end
end
