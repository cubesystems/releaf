require "spec_helper"

describe Releaf::Permissions::User do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:surname) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:locale) }
    it { should validate_presence_of(:email) }
    it { FactoryGirl.create(:user); should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { should belong_to(:role) }
  end

  describe "#display_name" do
    let(:user){ FactoryGirl.create(:user) }
    it "returns concated name and surname" do
      expect(user.display_name).to eq(user.name + " " + user.surname)
    end
  end
end
