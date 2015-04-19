require "spec_helper"

describe Releaf::Permissions::Role do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:default_controller) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
  end

  describe "#controller_permitted?" do
    context "when given controller name exists within permissions" do
      it "returns true" do
        subject.permissions.build(permission: "controller.a")
        subject.permissions.build(permission: "controller.x")
        expect(subject.controller_permitted?("x")).to be true
      end
    end

    context "when given controller name does not exist within permissions" do
      it "returns false" do
        subject.permissions.build(permission: "controller.a")
        expect(subject.controller_permitted?("x")).to be false
      end
    end
  end
end
