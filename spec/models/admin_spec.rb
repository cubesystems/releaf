require "spec_helper"

describe Releaf::Admin do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:surname) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:locale) }
    it { should validate_presence_of(:email) }
    it { FactoryGirl.create(:admin); should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { should belong_to(:role) }
  end

  describe "#display_name" do
    let(:admin){ FactoryGirl.create(:admin) }
    it "returns concated name and surname" do
      expect(admin.display_name).to eq(admin.name + " " + admin.surname)
    end
  end
end
