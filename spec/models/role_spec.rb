# encoding: UTF-8

require "spec_helper"

describe Releaf::Role do

  it { should have(1).error_on(:name) }

  describe "#uniqueness of name" do
    before do
      @role = FactoryGirl.create(:admin_role)
    end
  it { should validate_uniqueness_of(:name) }
  end

  describe "#default role" do
    before do
      @admin_role = FactoryGirl.create(:admin_role)
      @content_role = FactoryGirl.create(:content_role)
    end

    it "returns default role if no role defined" do
      @content_role.id.should eq(Releaf::Role.default.id)
    end

    it "set default role to admin_role" do
      @admin_role.default = true
      @admin_role.save
      @admin_role.id.should eq(Releaf::Role.default.id)
      @content_role.id.should_not eq(Releaf::Role.default.id)
    end
  end

  describe "#destroying" do
    before do
      @admin_role = FactoryGirl.create(:admin_role)
      @content_role = FactoryGirl.create(:content_role)
      @admin = FactoryGirl.create(:admin)
      @admin.role = @admin_role
      @admin.save
    end

    it "destroying of unused role" do
      expect { @content_role.destroy }.to change { Releaf::Role.count }.by(-1)
    end

    it "destroying of used role" do
      expect { @admin_role.destroy }.to change { Releaf::Role.count }.by(0)
    end
  end

  describe "#controller permissions" do
    before do
      @admin_role = FactoryGirl.create(:admin_role)
      @content_role = FactoryGirl.create(:content_role)
    end

    it "access to translations controller" do
      @admin_role.authorize!(Releaf::TranslationsController.new).should eq(true)
      @content_role.authorize!(Releaf::TranslationsController.new).should eq(false)
    end

    it "access to content controller" do
      @admin_role.authorize!(Releaf::ContentController.new).should eq(true)
      @content_role.authorize!(Releaf::ContentController.new).should eq(true)
    end
  end
end
