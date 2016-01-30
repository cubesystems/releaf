require "rails_helper"

describe Releaf::Permissions::Roles do
  describe ".draw_component_routes" do
    it "register roles resource route" do
      expect(described_class).to receive(:resource_route).with("_router", :permissions, :roles)
      described_class.draw_component_routes("_router")
    end
  end
end
