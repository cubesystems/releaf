# encoding: UTF-8

require "spec_helper"

describe Releaf::Admin do
  it { should have(1).error_on(:name) }
  it { should have(1).error_on(:surname) }
  it { should have(1).error_on(:role_id) }
  it { should have(1).error_on(:locale) }
  it { should have(2).error_on(:email) }

  describe "uniqueness of email" do
    before do
      @admin = FactoryGirl.create(:admin)
    end

    it { should validate_uniqueness_of(:email) }
  end

  describe "#display_name" do
    subject { FactoryGirl.create(:admin).display_name }

    it { should == 'Bill Withers' }
  end

  describe ".filter" do
    before do
      FactoryGirl.create(:admin, :name => 'Billy', :surname => 'Withers')
    end

    context "given there is user admin@example.com Billy Withers" do
      context "when filtering with 'admin@example.com bill with'" do
        it "returns 1 admin" do
          expect(Releaf::Admin.filter(:search => "admin@example.com bill with")).to have(1).admin
        end
      end

      context "when filtering with 'user@example.com bill with'" do
        it "returns 0 admins" do
          expect(Releaf::Admin.filter(:search => "user@example.com bill with")).to have(0).admins
        end
      end
    end
  end
end
