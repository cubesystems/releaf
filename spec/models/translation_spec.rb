# encoding: UTF-8

require "spec_helper"

describe I18n::Backend::Releaf::Translation do

  it { should have(1).error_on(:group_id) }
  it { should have(1).error_on(:key) }
  it {
    FactoryGirl.create(:translation)
    should validate_uniqueness_of(:key)
  }
  it { should belong_to(:translation_group) }


  before do
    Releaf.available_locales = ["de", "en"]
    Releaf.available_admin_locales = ["lv"]

    @group = FactoryGirl.create(:translation_group, :scope => 'test')
    @translation = FactoryGirl.create(:translation, :translation_group => @group, :key => 'test.apple')
    FactoryGirl.create(:translation_data, :localization => 'apple', :translation => @translation, :lang => "en")
    FactoryGirl.create(:translation_data, :localization => 'apfel', :translation => @translation, :lang => "de")

    Settings.i18n_updated_at = Time.now
  end

  after do
    # restore default values
    Releaf.available_locales = ["en"]
    Releaf.available_admin_locales = ["en"]
   end


  describe "scope: filter" do
    context "when filtering with 'apfel'" do
      it "returns 1 translation" do
        I18n::Backend::Releaf::Translation.filter(:search => "apfel").length.should eq(1)
      end
    end

    context "when filtering with 'ap' (group by test)" do
      it "returns 1 translation" do
        I18n::Backend::Releaf::Translation.filter(:search => "ap").length.should eq(1)
      end
    end

    context "when filtering with 'test.apple'" do
      it "returns 1 translation" do
        I18n::Backend::Releaf::Translation.filter(:search => "test.apple").length.should eq(1)
      end
    end

    context "when filtering with 'asdsad'" do
      it "returns 0 translation" do
        I18n::Backend::Releaf::Translation.filter(:search => "asdsad").length.should eq(0)
      end
    end
  end

  describe "#locales" do
    it "should return translated data values in hash" do
      @translation.locales.should eq({"en" => "apple", "de" => "apfel", "lv" => nil})
    end
  end

  describe "#plain_key" do
    it "should return plain key without group scope" do
      @translation.plain_key.should eq('apple')
    end
  end

  describe "translation data model relation" do
    it "should have relation to translation data" do
      @translation.translation_data.size.should eq(2)
    end

    it "should destroy translation data by destroying translation itself" do
      I18n::Backend::Releaf::TranslationData.all.count.should eq(2)
      @translation.destroy
      I18n::Backend::Releaf::TranslationData.all.count.should eq(0)
    end
  end
end
