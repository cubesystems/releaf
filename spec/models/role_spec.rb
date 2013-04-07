# encoding: UTF-8

require "spec_helper"

describe Releaf::Role do

  it { should have(1).error_on(:name) }

  describe "uniqueness of name" do
    before do
      @role = FactoryGirl.create(:admin_role)
    end
    it { should validate_uniqueness_of(:name) }
  end

  describe "#destroy" do
    before do
      @admin_role = FactoryGirl.create(:admin_role)
      @content_role = FactoryGirl.create(:content_role)
      @admin = FactoryGirl.create(:admin)
      @admin.role = @admin_role
      @admin.save
    end

    context "when role is not used" do
      it "destroys it" do
        expect { @content_role.destroy }.to change { Releaf::Role.count }.by(-1)
      end
    end

    context "when role is use" do
      it "does not doestry it" do
        expect { @admin_role.destroy }.to_not change { Releaf::Role.count }
      end
    end
  end

  describe "#authorize!" do
    before do
      @admin_role = FactoryGirl.create(:admin_role)
      @content_role = FactoryGirl.create(:content_role)
    end

    context "when permissions given" do
      it "return true" do
        @admin_role.authorize!(Releaf::TranslationsController.new).should be_true
        @admin_role.authorize!(Releaf::ContentController.new).should      be_true
        @content_role.authorize!(Releaf::ContentController.new).should    be_true
      end
    end

    context "when permissions not given" do
      it "returns false" do
        @content_role.authorize!(Releaf::TranslationsController.new).should be_false
      end
    end
  end
end
