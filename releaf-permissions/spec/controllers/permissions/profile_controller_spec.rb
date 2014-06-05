require 'spec_helper'

describe Releaf::Permissions::ProfileController do
  let(:another_role){ FactoryGirl.create(:content_role) }
  let(:user){ subject.current_releaf_permissions_user }
  login_as_user :user

  describe "#resource_class" do
    it "returns current releaf user user class" do
      expect(described_class.new.resource_class).to eq(Releaf::Permissions::User)
    end
  end

  describe "PATCH update" do
    context 'when attributes contain role_id' do
      it "does not update it" do
        expect{ patch :update, {resource: {role_id: another_role.id}} }.to_not change{ user.role_id }
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
        expect(user).to receive(:update_attributes).with(attributes)
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

      it "saves given data within current user settings" do
        put :settings, {settings: {dummy: 'maybe'}}
        expect(user.settings.dummy).to eq('maybe')
      end

      it "casts bolean values from strings to booleans" do
        put :settings, {settings: {be_true: 'true', be_false: 'false'}}
        expect(user.settings.be_true).to be true
        expect(user.settings.be_false).to be false
      end
    end
  end
end
