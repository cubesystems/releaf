require 'rails_helper'

describe Releaf::RootController do
  login_as_user :user

  describe "#features" do
    it "has no features" do
      expect(subject.features).to eq([])
    end
  end

  describe "GET home" do
    it "redirects to default controller resolver returned path authorized as user" do
      allow(Releaf.application.config.root.default_controller_resolver).to receive(:call)
        .with(current_controller: subject).and_return("_randompath_")
      get :home
      expect(response).to redirect_to("_randompath_")
    end
  end

  describe "PUT settings" do
    context 'when params[:settings] is not Hash' do
      it "has a 422 status code" do
        post :store_settings
        expect(Releaf.application.config.settings_manager).to_not receive(:write)
        expect(response.status).to eq(422)
      end
    end

    context 'when params[:settings] is Hash' do
      it "has a 200 status code" do
        allow(Releaf.application.config.settings_manager).to receive(:write)
        post :store_settings, settings: {dummy: 'maybe'}
        expect(response.status).to eq(200)
      end

      it "saves given data within current user settings, casting true/false strings to boolean" do
        expect(Releaf.application.config.settings_manager).to receive(:write).with(controller: subject, key: "dummy", value: "maybe")
        expect(Releaf.application.config.settings_manager).to receive(:write).with(controller: subject, key: "be_true", value: true)
        expect(Releaf.application.config.settings_manager).to receive(:write).with(controller: subject, key: "be_false", value: false)
        post :store_settings, settings: {dummy: "maybe", be_true: 'true', be_false: 'false'}
      end
    end
  end
end
