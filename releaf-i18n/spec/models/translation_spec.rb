require "spec_helper"

describe Releaf::Translation do

  it { should validate_presence_of(:key) }
  it { should ensure_length_of(:key).is_at_most(255) }
  it do
    FactoryGirl.create(:translation)
    should validate_uniqueness_of(:key)
  end
  it { should have_many(:translation_data).dependent(:destroy) }
  it { should accept_nested_attributes_for(:translation_data).allow_destroy(true) }


  before do
    Releaf.stub(:available_locales) { ["de", "en"] }
    Releaf.stub(:available_admin_locales) { ["lv"] }

    @translation = FactoryGirl.create(:translation, :key => 'test.apple')
    FactoryGirl.create(:translation_data, :localization => 'apple', :translation => @translation, :lang => "en")
    FactoryGirl.create(:translation_data, :localization => 'apfel', :translation => @translation, :lang => "de")

    Settings.i18n_updated_at = Time.now
  end

  describe "#locales" do
    it "returns translated data values in hash" do
      expect(@translation.locales).to eq({"en" => "apple", "de" => "apfel", "lv" => nil})
    end
  end

  describe "translation" do
    it "has relation to translation data" do
      expect(@translation.translation_data.size).to eq(2)
    end

    it "destroys translation data when destroying translation itself" do
      expect{ @translation.destroy }.to change{ Releaf::TranslationData.all.count }.from(2).to(0)
    end
  end
end
