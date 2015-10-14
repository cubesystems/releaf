require "spec_helper"

describe Releaf::I18nDatabase::Translation do

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_length_of(:key).is_at_most(255) }
  it do
    FactoryGirl.create(:translation)
    is_expected.to validate_uniqueness_of(:key)
  end
  it { is_expected.to have_many(:translation_data).dependent(:destroy) }
  it { is_expected.to accept_nested_attributes_for(:translation_data).allow_destroy(true) }


  before do
    allow(Releaf.application.config).to receive(:available_locales) { ["de", "en"] }
    allow(Releaf.application.config).to receive(:available_admin_locales) { ["lv"] }

    @translation = FactoryGirl.create(:translation, :key => 'test.apple')
    FactoryGirl.create(:translation_data, :localization => 'apple', :translation => @translation, :lang => "en")
    FactoryGirl.create(:translation_data, :localization => 'apfel', :translation => @translation, :lang => "de")

    I18n.backend.reload_cache
  end

  describe "translation" do
    it "has relation to translation data" do
      expect(@translation.translation_data.size).to eq(2)
    end

    it "destroys translation data when destroying translation itself" do
      expect{ @translation.destroy }.to change{ Releaf::I18nDatabase::TranslationData.all.count }.from(2).to(0)
    end
  end

  describe "#locale_value" do
    it "returns translated value for given locale" do
      expect(@translation.locale_value("en")).to eq("apple")
      expect(@translation.locale_value("de")).to eq("apfel")
      expect(@translation.locale_value("lt")).to eq(nil)
    end

    it "caches translated values with first call" do
      expect(@translation.locale_value("en")).to eq("apple")
      Releaf::I18nDatabase::TranslationData.destroy_all
      expect(@translation.locale_value("de")).to eq("apfel")
    end
  end
end
