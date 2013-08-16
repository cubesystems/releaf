require 'spec_helper'

describe Releaf::AdminProfileController do
  let(:another_role){ FactoryGirl.create(:content_role) }
  let(:admin){ subject.current_releaf_admin }
  login_as_admin :admin

  describe "PUT update" do
    context 'when attributes contain role_id' do
      it "does not update it" do
        expect{ put :update, {resource: {role_id: another_role.id}} }.to_not change{ admin.role_id }
      end
    end

    context 'with allowed attributes' do
      it "save new attributes" do
        expect{ put :update, {resource: {name: "new name"}} }.to change{ admin.name }
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

      it "save given data within current admin settings" do
        put :settings, {settings: {dummy: 'maybe'}}
        expect(admin.settings.dummy).to eq('maybe')
      end

      it "cast bolean values from strings to booleans" do
        put :settings, {settings: {be_true: 'true', be_false: 'false'}}
        expect(admin.settings.all).to eq({"be_true" => true, "be_false" => false})
      end
    end
  end
end
