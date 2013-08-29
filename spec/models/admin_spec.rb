# encoding: UTF-8

require "spec_helper"

describe Releaf::Admin do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:surname) }
    it { should validate_presence_of(:role_id) }
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

  describe ".filter" do
    before do
      FactoryGirl.create(:admin)
      @subject = FactoryGirl.create(:admin)
    end

    context "when :search hash key given" do
      context "when given value match to name, surname or email" do
        it "returns matched records" do
          expect(Releaf::Admin.filter(search: "#{@subject.email} #{@subject.name} #{@subject.surname}")).to have(1).admin
        end
      end

      context "when given value match no records" do
        it "returns empty set" do
          expect(Releaf::Admin.filter(search: "user@example.com bill with")).to have(0).admins
        end
      end
    end
  end
end
