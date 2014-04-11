# encoding: UTF-8

require "spec_helper"

describe Releaf::Role do
  it { should serialize(:permissions).as(Array) }
  it { should have_many(:admins).dependent(:restrict_with_exception) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:default_controller) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:admins).dependent(:restrict_with_exception) }
  end

  describe "#authorize!" do
    before do
      @admin_role = FactoryGirl.create(:admin_role)
      @content_role = FactoryGirl.create(:content_role)
      @role_without_permissions = FactoryGirl.create(:content_role, :permissions => [])
    end

    context "when arguments that are neither String or class that inherit ActionController::Base given" do
      it "raises ArgumentError" do
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

    context "when permissions given" do
      it "returns true" do
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
