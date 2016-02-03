require "rails_helper"

describe Releaf::Permissions::DefaultControllerResolver do
  subject{ described_class.new(current_controller: Releaf::RootController.new) }

  it "inherit `Releaf::Root::DefaultControllerResolver`" do
    expect(described_class.ancestors.include?(Releaf::Root::DefaultControllerResolver)).to be true
  end

  describe ".configure_component" do
    it "adds itself as default controller resolver" do
      expect(Releaf.application.config.root).to receive(:default_controller_resolver=).with(described_class)
      described_class.configure_component
    end
  end

  describe "#controllers" do
    it "returns user available controllers with role default controller as first" do
      role = Releaf::Permissions::Role.new(default_controller: "a")
      user = Releaf::Permissions::User.new(role: role)
      allow(Releaf.application.config).to receive(:available_controllers).and_return(["a", "b", "c"])
      allow(subject).to receive(:user).and_return(user)

      allow(subject).to receive(:allowed_controllers).and_return(["a", "c", "d"])
      expect(subject.controllers).to eq(["a", "c"])

      allow(subject).to receive(:allowed_controllers).and_return(["c", "d"])
      expect(subject.controllers).to eq(["c"])
    end
  end

  describe "#allowed_controllers" do
    it "returns allowed controllers from access contro for given user" do
      allow(subject).to receive(:user).and_return("_user")
      access_control = Releaf::Permissions::AccessControl.new(user: Releaf::Permissions::User.new)
      allow(access_control).to receive(:allowed_controllers).and_return(["a", "d"])
      allow(Releaf.application.config.permissions.access_control).to receive(:new).with(user: "_user").and_return(access_control)

      expect(subject.allowed_controllers).to eq(["a", "d"])
    end
  end

  describe "#user" do
    it "returns controller user" do
      allow(subject.current_controller).to receive(:user).and_return("_user")
      expect(subject.user).to eq("_user")
    end
  end
end
