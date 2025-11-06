require "rails_helper"

describe "FactoryBot factories" do

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
end
