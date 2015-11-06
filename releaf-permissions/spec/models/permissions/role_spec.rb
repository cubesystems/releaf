require "rails_helper"

describe Releaf::Permissions::Role do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:default_controller) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
  end

  describe "#controller_permitted?" do
    before do
      allow(subject).to receive(:allowed_controllers).and_return(["a", "b"])
    end

    context "when given controller name exists within permissions" do
      it "returns true" do
        expect(subject.controller_permitted?("a")).to be true
        expect(subject.controller_permitted?("b")).to be true
      end
    end

    context "when given controller name does not exist within permissions" do
      it "returns false" do
        expect(subject.controller_permitted?("c")).to be false
      end
    end
  end

  describe "#allowed_controllers" do
    it "returns array of roles allowed controllers" do
      subject.permissions.build(permission: "controller.a")
      subject.permissions.build(permission: "controller.x")
      subject.permissions.build(permission: "export.some_data")
      expect(subject.allowed_controllers).to match_array(["a", "x"])
    end
  end
end
