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

end
