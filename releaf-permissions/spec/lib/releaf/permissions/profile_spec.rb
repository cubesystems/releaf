require "rails_helper"

describe Releaf::Permissions::Profile do
  describe ".initialize_component" do
    it "adds `releaf/permissions/profile` to additional controllers" do
      expect(Releaf.application.config.additional_controllers).to receive(:push).with("releaf/permissions/profile")
      described_class.initialize_component
    end
  end
end
