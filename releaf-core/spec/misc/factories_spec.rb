require "spec_helper"

describe "FactoryGirl factories" do

  describe "admin factory" do
    it "creates new admin" do
      expect { FactoryGirl.create(:admin) }.to change { Releaf::Permissions::Admin.count }.by(1)
    end
  end

  describe "role factory" do
    it "creates new role" do
      expect { FactoryGirl.create(:admin_role) }.to change { Releaf::Permissions::Role.count }.by(1)
    end
  end

  describe "translation factory" do
    it "creates new translation" do
      expect { FactoryGirl.create(:translation) }.to change { Releaf::I18nDatabase::Translation.count }.by(1)
    end
  end

  describe "translation data factory" do
    it "creates new translation data" do
      expect { FactoryGirl.create(:translation_data) }.to change { Releaf::I18nDatabase::TranslationData.count }.by(1)
    end
  end

  describe "node factory" do
    it "creates new content node" do
      expect { FactoryGirl.create(:node) }.to change { Node.count }.by(1)
    end

    it "creates new Text content node" do
      expect { FactoryGirl.create(:text_node) }.to change { Text.count }.by(1)
    end
  end
end
