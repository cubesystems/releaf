require "spec_helper"

describe Releaf::Permissions::Role do
  it { is_expected.to serialize(:permissions).as(Array) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:default_controller) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
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
        expect(@admin_role.authorize!(Releaf::HomeController.new)).to be true
        expect(@content_role.authorize!(Releaf::HomeController.new)).to be true
        expect(@role_without_permissions.authorize!(Releaf::HomeController.new)).to be true
      end
    end

    context "when permissions given" do
      it "returns true" do
        expect(@admin_role.authorize!(Releaf::I18nDatabase::TranslationsController.new)).to be true
        expect(@admin_role.authorize!(Releaf::Content::NodesController.new)).to be true
        expect(@content_role.authorize!(Releaf::Content::NodesController.new)).to  be true
        expect(@role_without_permissions.authorize!(Releaf::Content::NodesController.new)).to be false
      end
    end

    context "when permissions not given" do
      it "returns false" do
        expect(@content_role.authorize!(Releaf::I18nDatabase::TranslationsController.new)).to be false
        expect(@role_without_permissions.authorize!(Releaf::I18nDatabase::TranslationsController.new)).to be false
      end
    end
  end
end
