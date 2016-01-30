require "rails_helper"

describe Releaf::Permissions::Profile do
  describe ".configure_component" do
    it "adds `releaf/permissions/profile` to additional controllers" do
      expect(Releaf.application.config).to receive(:additional_controllers).and_return(["a", "b"])
      expect(Releaf.application.config).to receive(:additional_controllers=).with(["a", "b", "releaf/permissions/profile"])
      described_class.configure_component
    end
  end
end
