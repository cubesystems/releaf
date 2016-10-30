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

  describe "#find_or_initialize_translation" do
    before do
      subject.key = "xx"
      subject.i18n_entry_translation.build(text: 'apple', locale: "en")
      subject.i18n_entry_translation.build(text: 'ābols', locale: "lv")
      subject.save
      allow(subject.i18n_entry_translation).to receive(:build).with(locale: "de").and_return(:new)
    end

    context "when translation exists for given locale (given as string or symbol)" do
      it "returns existing translation instance" do
        expect(subject.find_or_initialize_translation(:en).text).to eq("apple")
        expect(subject.find_or_initialize_translation("en").text).to eq("apple")
      end

      it "uses AR cache to prevent multiple db hit for multiple locales lookup" do
        expect {
          subject.find_or_initialize_translation("en")
          subject.find_or_initialize_translation("lv")
        }.to make_database_queries(count: 1)
      end
    end

    context "when translation does not exists for given locale" do
      it "returns newly builded translation instance" do
        expect(subject.find_or_initialize_translation("de")).to eq(:new)
      end
    end
  end
end
