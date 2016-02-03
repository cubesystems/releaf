require 'rails_helper'

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

        # This is needed in order to get same instance as we expect.
        # Otherwise we'll get same record, but different instance and test will fail
        allow( user ).to receive(:becomes).with(Releaf::Permissions::User).and_return(user)

        expect(user).to receive(:update_attributes).with(attributes)
        patch :update, {resource: attributes}
      end
    end
  end
end
