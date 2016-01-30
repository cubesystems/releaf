require "rails_helper"

describe Releaf::Permissions::Users do
  describe ".configure_component" do
    it "sets `releaf/permissions/user` as devise model" do
      expect(Releaf.application.config.permissions).to receive(:devise_for=).with("releaf/permissions/user")
      described_class.configure_component
    end
  end

  describe ".draw_component_routes" do
    it "register users resource route" do
      expect(described_class).to receive(:resource_route).with("_router", :permissions, :users)
      described_class.draw_component_routes("_router")
    end
  end
end
