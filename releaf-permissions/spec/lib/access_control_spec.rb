require "rails_helper"

describe Releaf::Permissions::AccessControl do
  let(:role){ Releaf::Permissions::Role.new }
  let(:user){ Releaf::Permissions::User.new(role: role) }
  subject{ described_class.new(user: user) }


  describe "#controller_permitted?" do
    context "when allowed controllers contains given controller" do
      it "returns true" do
        allow(subject).to receive(:allowed_controllers).and_return(["a", "b"])
        expect(subject.controller_permitted?("a")).to be true
      end
    end

    context "when allowed controllers does not contain given controller" do
      it "returns false" do
        allow(subject).to receive(:allowed_controllers).and_return(["c", "b"])
        expect(subject.controller_permitted?("a")).to be false
      end
    end
  end

  describe "#allowed_controllers" do
    it "returns array with permanent allowed controllers and role allowed controllers" do
      allow(subject).to receive(:permanent_allowed_controllers).and_return(["a", "b"])
      allow(subject).to receive(:role_allowed_controllers).and_return(["c", "d"])
      expect(subject.allowed_controllers).to eq(%w(a b c d))
    end
  end

  describe "#permanent_allowed_controllers" do
    it "returns array with permanent allowed controllers" do
      allow(Releaf.application.config.permissions).to receive(:permanent_allowed_controllers).and_return("x")
      expect(subject.permanent_allowed_controllers).to eq("x")
    end
  end

  describe "#role_allowed_controllers" do
    it "returns array of roles allowed controllers" do
      role.permissions.build(permission: "controller.a")
      role.permissions.build(permission: "controller.x")
      role.permissions.build(permission: "export.some_data")
      allow(subject).to receive(:controller_name_from_permission).with("controller.a").and_return(nil)
      allow(subject).to receive(:controller_name_from_permission).with("controller.x").and_return("asd")
      allow(subject).to receive(:controller_name_from_permission).with("export.some_data").and_return("fd")

      expect(subject.role_allowed_controllers).to match_array(["asd", "fd"])
    end
  end

  describe "#controller_name_from_permission" do
    context "when given permission contains `controller`" do
      it "returns name" do
        expect(subject.controller_name_from_permission("controller.a")).to eq("a")
      end
    end

    context "when given permission does not contain `controller`" do
      it "returns nil" do
        expect(subject.controller_name_from_permission("aasd.a")).to be nil
      end
    end
  end
end
