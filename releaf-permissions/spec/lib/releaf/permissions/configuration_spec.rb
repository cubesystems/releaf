require "rails_helper"

describe Releaf::Permissions::Configuration do
  subject{ described_class.new(devise_for: "asd", access_control: "X", permanent_allowed_controllers: [1, 2]) }

  it do
    is_expected.to have_attributes(devise_for: "asd")
    is_expected.to have_attributes(access_control: "X")
    is_expected.to have_attributes(permanent_allowed_controllers: [1, 2])
  end

  describe "#devise_model_name" do
    it "returns devise model name with slashes replaced by underscores" do
      subject.devise_for = "releaf/permissions/user"
      expect(subject.devise_model_name).to eq("releaf_permissions_user")
    end
  end

  describe "#devise_model_class" do
    it "returns devise model class" do
      subject.devise_for = "releaf/permissions/role"
      expect(subject.devise_model_class).to eq(Releaf::Permissions::Role)
    end
  end

  describe ".component_configuration" do
    it "returns instance of itself" do
      allow(described_class).to receive(:new).and_return("_a")
      expect(described_class.component_configuration).to eq("_a")
    end
  end
end
