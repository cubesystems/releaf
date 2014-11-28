require 'spec_helper'

describe Releaf::Builder::Utility, type: :class do
  describe ".builder_class" do
    it "returns builder class for given controller, model and builder type" do
      expect(described_class.builder_class(Releaf::Permissions::UsersController, Releaf::Permissions::User, :form)).to eq(Releaf::Permissions::UserFormBuilder)
    end

    context "when custom builder class does not exists for given controller, model and builder type" do
      it "returns default builder class" do
        expect(described_class.builder_class(Admin::AuthorsController, Author, :form)).to eq(Releaf::FormBuilder)
      end
    end
  end

  describe ".builder_class_name" do
    it "returns builder class name for given controller name, model name and builder type" do
      expect(described_class.builder_class_name("Releaf::Permissions::UsersController", "Releaf::Permissions::User", :form)).to eq("Releaf::Permissions::UserFormBuilder")
      expect(described_class.builder_class_name("Admin::UsersController", "User", :form)).to eq("Admin::UserFormBuilder")
      expect(described_class.builder_class_name("Admin::Valuation::ApplicationController", "Valuation::Application", :table)).to eq("Admin::Valuation::ApplicationTableBuilder")
    end
  end
end
