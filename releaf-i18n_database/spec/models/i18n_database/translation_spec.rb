require "rails_helper"

describe Releaf::I18nDatabase::Translation do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_length_of(:key).is_at_most(255) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to have_many(:translation_data).dependent(:destroy) }
  it { is_expected.to accept_nested_attributes_for(:translation_data).allow_destroy(true) }

  describe "#locale_value" do
    it "returns translated value for given locale" do
      subject.translation_data.build(localization: 'apple', lang: "en")
      subject.translation_data.build(localization: 'apfel', lang: "de")

      expect(subject.locale_value("en")).to eq("apple")
      expect(subject.locale_value(:de)).to eq("apfel")
      expect(subject.locale_value("lt")).to be nil
    end
  end
end
