require "rails_helper"

describe "FactoryGirl factories" do

  describe "admin factory" do
    it "creates new user" do
      expect { create(:user) }.to change { Releaf::Permissions::User.count }.by(1)
    end
  end

  describe "role factory" do
    it "creates new role" do
      expect { create(:admin_role) }.to change { Releaf::Permissions::Role.count }.by(1)
    end
  end

  describe "node factory" do
    it "creates new content node" do
      expect { create(:node) }.to change { Node.count }.by(1)
    end

    it "creates new HomePage content node" do
      expect { create(:home_page_node) }.to change { HomePage.count }.by(1)
    end

    it "creates new TextPage content node" do
      parent = create(:home_page_node)
      expect { create(:text_page_node, parent: parent) }.to change { TextPage.count }.by(1)
    end
  end
end
