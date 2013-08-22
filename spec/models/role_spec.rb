# encoding: UTF-8

require "spec_helper"

describe Releaf::Role do

  it { should have(1).error_on(:name) }
  it { should have(1).error_on(:default_controller) }

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
      @role_without_permissions = FactoryGirl.create(:content_role, :permissions => [])
    end

    context "when arguments that are neither String or class that inherit ActionController::Base given" do
      it "raise ArgumentError" do
        expect{ @content_role.authorize!([]) }.to raise_error(ArgumentError)
      end
    end

    context "when access to releaf/home controller authorized" do
      it "always return true" do
        expect(@admin_role.authorize!(Releaf::HomeController.new)).to be_true
        expect(@content_role.authorize!(Releaf::HomeController.new)).to be_true
        expect(@role_without_permissions.authorize!(Releaf::HomeController.new)).to be_true
      end
    end

    context "when access to releaf/tinymce_assets controller authorized" do
      it "always return true if role has permissions to access releaf/content controller" do
        expect(@admin_role.authorize!(Releaf::TinymceAssetsController.new)).to be_true
        expect(@content_role.authorize!(Releaf::TinymceAssetsController.new)).to be_true
        expect(@role_without_permissions.authorize!(Releaf::TinymceAssetsController.new)).to be_false
      end
    end

    context "when permissions given" do
      it "return true" do
        expect(@admin_role.authorize!(Releaf::TranslationsController.new)).to be_true
        expect(@admin_role.authorize!(Releaf::ContentController.new)).to be_true
        expect(@content_role.authorize!(Releaf::ContentController.new)).to  be_true
        expect(@role_without_permissions.authorize!(Releaf::ContentController.new)).to be_false
      end
    end

    context "when permissions not given" do
      it "returns false" do
        expect(@content_role.authorize!(Releaf::TranslationsController.new)).to be_false
        expect(@role_without_permissions.authorize!(Releaf::TranslationsController.new)).to be_false
      end
    end
  end
end
