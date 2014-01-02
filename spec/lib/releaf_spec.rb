require "spec_helper"

describe Releaf do
  describe ".available_controllers" do
    it "returns all available controllers" do
      expect(Releaf.available_controllers).to eq(["releaf/content", "admin/books", "admin/authors", "releaf/admins", "releaf/roles", "releaf/translations", "admin/chapters"])
    end
  end
end
