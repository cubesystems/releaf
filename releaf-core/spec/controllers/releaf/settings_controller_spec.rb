require 'rails_helper'

describe Releaf::SettingsController do
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

  describe "PATCH update" do
    login_as_user :user
    it "updates settings object with normalized value" do
      Releaf::Settings.destroy_all
      Releaf::Settings.registry = {}
      Releaf::Settings.register(key: "a", default: false, type: "boolean")

      allow(Releaf::Settings::NormalizeValue).to receive(:call).
        with(value: "1", input_type: :boolean).and_return(88)

      patch :update, {id: Releaf::Settings.first.id, resource: {value: "1"}}
      expect(Releaf::Settings.first.value).to eq(88)
    end
  end

  describe "#features" do
    it "has `index`, `search` and `edit` features" do
      expect(subject.features).to eq([:index, :edit, :search])
    end
  end

  describe "#resources" do
    it "returns only registered settings ordered by `var`" do
      allow(Releaf::Settings).to receive(:registered).and_return(:x)
      expect(subject.resources).to eq(:x)
    end
  end
end
