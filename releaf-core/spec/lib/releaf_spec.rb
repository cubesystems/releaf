require "spec_helper"

describe Releaf do
  describe ".available_controllers" do
    it "returns all available controllers" do
      expect(Releaf.available_controllers).to eq(["releaf/content/nodes", "admin/books", "admin/authors", "releaf/permissions/admins", "releaf/permissions/roles", "releaf/i18n_database/translations", "admin/chapters"])
    end
  end
end
