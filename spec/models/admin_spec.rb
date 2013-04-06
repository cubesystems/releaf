# encoding: UTF-8

require "spec_helper"

describe Releaf::Admin do

  it { should have(1).error_on(:name) }
  it { should have(1).error_on(:surname) }
  it { should have(1).error_on(:role_id) }
  it { should have(1).error_on(:locale) }
  it { should have(2).error_on(:email) }

  describe "#uniqueness of email" do
    before do
      @admin = FactoryGirl.create(:admin)
    end
  it { should validate_uniqueness_of(:email) }
  end

  describe "#display_name" do
    before do
      @admin = FactoryGirl.create(:admin)
    end
    subject { @admin.display_name }

    it { should == 'Bill Withers' }
  end

  describe "#default role" do
    before do
      @role = FactoryGirl.create(:content_role)
      @customer = Releaf::Admin.new(
        :email => 'customer@example.com',
        :locale => 'en',
        :password => 'password',
        :password_confirmation => 'password'
      )
    end

    it "returns default role if no role defined" do
      @customer.role.id.should eq(Releaf::Role.default.id)
    end

  end

  describe "#filter scope" do
    before do
      @admin = FactoryGirl.create(:admin)
    end

    it "returns 1 result for filtering with email, name, surname value" do
      result = Releaf::Admin.filter(:search => "admin@example.com bill with")
      result.count.should eq(1)
    end

    it "returns 9 result for filtering with name, surname" do
      result = Releaf::Admin.filter(:search => "user@example.com bill with")
      result.count.should eq(0)
    end
  end

end
