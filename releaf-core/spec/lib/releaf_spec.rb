require "spec_helper"

describe Releaf do
  describe ".available_controllers" do
    it "returns all available controllers" do
      expect(Releaf.available_controllers).to eq(["releaf/content/nodes", "admin/books", "admin/authors", "releaf/permissions/admins", "releaf/permissions/roles", "releaf/translations", "admin/chapters"])
    end
  end
end
