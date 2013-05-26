require 'spec_helper'

describe I18n::Backend::Releaf do
  before do
    Settings.i18n_updated_at = Time.now
  end

  it "should humanize missing translation" do
    I18n.t("admin.products.create_new_item").should eq("Create new item")
  end

  describe "when missing translation with scope called" do
    it "should create missing translation and translation group in database" do
      I18n::Backend::Releaf::Translation.all.count.should eq(0)
      I18n::Backend::Releaf::TranslationGroup.all.count.should eq(0)
      I18n.t("create_new_item", :scope => "admin.products")
      I18n::Backend::Releaf::Translation.all.count.should eq(1)
      I18n::Backend::Releaf::TranslationGroup.all.count.should eq(1)
      I18n::Backend::Releaf::Translation.last.key.should eq("admin.products.create_new_item")
      I18n::Backend::Releaf::TranslationGroup.last.scope.should eq("admin.products")
      I18n::Backend::Releaf::TranslationGroup.last.id.should eq(I18n::Backend::Releaf::Translation.last.group_id)
    end
  end

  describe "when missing translation without scope called" do
    it "should create missing translation and translation group in database with default scope" do
      I18n::Backend::Releaf::Translation.all.count.should eq(0)
      I18n::Backend::Releaf::TranslationGroup.all.count.should eq(0)
      I18n.t("create_new_item")
      I18n::Backend::Releaf::Translation.all.count.should eq(1)
      I18n::Backend::Releaf::TranslationGroup.all.count.should eq(1)
      I18n::Backend::Releaf::Translation.last.key.should eq("global.create_new_item")
      I18n::Backend::Releaf::TranslationGroup.last.scope.should eq("global")
      I18n::Backend::Releaf::TranslationGroup.last.id.should eq(I18n::Backend::Releaf::Translation.last.group_id)
    end
  end
end

