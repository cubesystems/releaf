# encoding: UTF-8

require "spec_helper"

describe I18n::Backend::Releaf::Translation do

  it { should have(1).error_on(:translation_group) }
  it { should have(1).error_on(:key) }
  it {
    FactoryGirl.create(:translation)
    should validate_uniqueness_of(:key)
  }
  it { should belong_to(:translation_group) }


  before do
    Releaf.stub(:available_locales) { ["de", "en"] }
    Releaf.stub(:available_admin_locales) { ["lv"] }

    @group = FactoryGirl.create(:translation_group, :scope => 'test')
    @translation = FactoryGirl.create(:translation, :translation_group => @group, :key => 'test.apple')
    FactoryGirl.create(:translation_data, :localization => 'apple', :translation => @translation, :lang => "en")
    FactoryGirl.create(:translation_data, :localization => 'apfel', :translation => @translation, :lang => "de")

    Settings.i18n_updated_at = Time.now
  end

  describe "scope: filter" do
    context "when filtering with 'apfel'" do
      it "returns 1 translation" do
        expect(I18n::Backend::Releaf::Translation.filter(:search => "apfel").length).to eq(1)
      end
    end

    context "when filtering with 'ap' (group by test)" do
      it "returns 1 translation" do
        expect(I18n::Backend::Releaf::Translation.filter(:search => "ap").length).to eq(1)
      end
    end

    context "when filtering with 'test.apple'" do
      it "returns 1 translation" do
        expect(I18n::Backend::Releaf::Translation.filter(:search => "test.apple").length).to eq(1)
      end
    end

    context "when filtering with 'asdsad'" do
      it "returns 0 translation" do
        expect(I18n::Backend::Releaf::Translation.filter(:search => "asdsad").length).to eq(0)
      end
    end
  end

  describe "#locales" do
    it "return translated data values in hash" do
      expect(@translation.locales).to eq({"en" => "apple", "de" => "apfel", "lv" => nil})
    end
  end

  describe "#plain_key" do
    it "return plain key without group scope" do
      expect(@translation.plain_key).to eq('apple')
    end
  end

  describe "translation data model relation" do
    it "have relation to translation data" do
      expect(@translation.translation_data.size).to eq(2)
    end

    it "destroy translation data when destroying translation itself" do
      expect{ @translation.destroy }.to change{ I18n::Backend::Releaf::TranslationData.all.count }.from(2).to(0)
    end
  end
end
