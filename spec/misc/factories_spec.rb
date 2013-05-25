require "spec_helper"

describe "FactoryGirl factories" do

  describe "admin factory" do
    it "creates new admin" do
      expect { FactoryGirl.create(:admin) }.to change { Releaf::Admin.count }.by(1)
    end
  end

  describe "role factory" do
    it "creates new role" do
      expect { FactoryGirl.create(:admin_role) }.to change { Releaf::Role.count }.by(1)
    end
  end

  describe "translation group factory" do
    it "creates new translation group" do
      expect { FactoryGirl.create(:translation_group) }.to change { I18n::Backend::Releaf::TranslationGroup.count }.by(1)
    end
  end

  describe "translation factory" do
    it "creates new translation" do
      expect { FactoryGirl.create(:translation) }.to change { I18n::Backend::Releaf::Translation.count }.by(1)
    end
  end

  describe "translation data factory" do
    it "creates new translation data" do
      expect { FactoryGirl.create(:translation_data) }.to change { I18n::Backend::Releaf::TranslationData.count }.by(1)
    end
  end
end
