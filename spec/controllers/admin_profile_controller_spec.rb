require 'spec_helper'

describe Releaf::AdminProfileController do
  let(:another_role){ FactoryGirl.create(:content_role) }
  let(:admin){ subject.current_releaf_admin }
  login_as_admin :admin

  describe "#resource_class" do
    it "returns current releaf admin user class" do
      expect(Releaf::AdminProfileController.new.resource_class).to eq(Releaf::Admin)
    end
  end

  describe "PATCH update" do
    context 'when attributes contain role_id' do
      it "does not update it" do
        expect{ patch :update, {resource: {role_id: another_role.id}} }.to_not change{ admin.role_id }
      end
    end

    context 'with allowed attributes' do
      it "saves new attributes" do
        attributes = {
          "name" => "new name",
          "surname" => "new surname",
          "email" => "new.email@example.com",
          "locale" => "lv"
        }
        admin.should_receive(:update_attributes).with(attributes)
        patch :update, {resource: attributes}
      end
    end
  end

  describe "PUT settings" do
    context 'when params[:settings] is not Hash' do
      it "has a 422 status code" do
        put :settings
        expect(response.status).to eq(422)
      end
    end

    context 'when params[:settings] is Hash' do
      it "has a 200 status code" do
        put :settings, {settings: {dummy: 'maybe'}}
        expect(response.status).to eq(200)
      end

      it "saves given data within current admin settings" do
        put :settings, {settings: {dummy: 'maybe'}}
        expect(admin.settings.dummy).to eq('maybe')
      end

      it "casts bolean values from strings to booleans" do
        put :settings, {settings: {be_true: 'true', be_false: 'false'}}
        expect(admin.settings.be_true).to be_true
        expect(admin.settings.be_false).to be_false
      end
    end
  end
end
