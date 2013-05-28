# encoding: UTF-8

require "spec_helper"

describe I18n::Backend::Releaf::TranslationGroup do

  it { should have(1).error_on(:scope) }
  it { should validate_uniqueness_of(:scope) }

  before do
    @group = FactoryGirl.create(:translation_group, :scope => 'test')
  end

  describe "#to_s" do
    it "should return scope" do
      @group.to_s.should eq('test')
    end
  end

  describe "translation model relation" do
    before do
      FactoryGirl.create(:translation, :key => 'test.yumberry', :translation_group => @group)
      FactoryGirl.create(:translation, :key => 'test.apple', :translation_group => @group)
      FactoryGirl.create(:translation, :key => 'test.orange', :translation_group => @group)
    end

    it "should have relation to translations" do
      @group.translations.size.should eq(3)
    end

    it "should have translations order by key" do
      @group.translations[0].key.should eq('test.apple')
      @group.translations[1].key.should eq('test.orange')
      @group.translations[2].key.should eq('test.yumberry')
    end

    it "should destroy translations by destroying group itself" do
      expect { @group.destroy }.to change { I18n::Backend::Releaf::Translation.count }.from(3).to(0)
    end
  end
end
