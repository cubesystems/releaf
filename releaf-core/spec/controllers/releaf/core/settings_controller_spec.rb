require 'rails_helper'

describe Releaf::Core::SettingsController do
  login_as_user :user

  describe "GET index" do
    login_as_user :user
    it "lists only settings that not scoped to any object and exists within `Releaf::Settings.registry`" do
      Releaf::Settings.destroy_all
      Releaf::Settings.registry = {}

      Releaf::Settings.create(var: "a", value: "1")
      Releaf::Settings.create(var: "b", value: "2")
      Releaf::Settings.create(var: "c", value: "2")
      Releaf::Settings.create(var: "a", value: "3", thing_type: "User", thing_id: "1")

      Releaf::Settings.register(key: "a", default: "x", description: "some setting")
      Releaf::Settings.register(key: "b", default: "xxxx", description: "some other setting")

      get :index
      expect(assigns(:collection).size).to eq(2)
    end
  end

  describe "GET new" do
    it "creation of new records is disabled" do
      get :new
      expect(response.status).to eq(403)
    end
  end
end
