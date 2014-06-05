require 'spec_helper'
describe "Errors feature" do
  before do
    auth_as_user
  end

  it "returns 404 status code and generic error page for nonexistent rotues" do
    visit(releaf_root_path + "/asdassd")

    expect(page.status_code).to eq(404)
    expect(page.body).to match(/not found/)
  end

  it "returns 403 status code and generic error page for disabled feature" do
    allow_any_instance_of(Releaf::Permissions::RolesController).to receive(:check_feature).and_raise(Releaf::FeatureDisabled, "edit")
    visit releaf_permissions_roles_path

    expect(page.status_code).to eq(403)
    expect(page.body).to match(/edit feature disabled for roles/i)
  end

  it "returns 403 status code and generic error page for restricted content" do
    allow_any_instance_of(Releaf::Permissions::Role).to receive(:authorize!).and_return(false)
    visit releaf_permissions_roles_path

    expect(page.status_code).to eq(403)
    expect(page.body).to match(/you are not authorized to access roles/i)
  end
end
