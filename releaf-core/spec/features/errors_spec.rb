require 'rails_helper'
describe "Errors feature" do
  before do
    auth_as_user
  end

  it "returns 404 status code and generic error page for nonexistent records" do
    visit "/admin/users/712323/edit"

    expect(page.status_code).to eq(404)
    within "main" do
      expect(page).to have_text("Page not found")
      expect(page).to have_text("You may have mistyped the address or the page may have moved")
    end
  end

  it "returns 404 status code and generic error page for nonexistent routes" do
    visit(releaf_root_path + "/asdassd")

    expect(page.status_code).to eq(404)
    within "main" do
      expect(page).to have_text("Page not found")
      expect(page).to have_text("You may have mistyped the address or the page may have moved")
    end
  end

  it "returns 403 status code and generic error page for disabled feature" do
    allow_any_instance_of(Releaf::Permissions::RolesController).to receive(:verify_feature_availability!)
      .and_raise(Releaf::FeatureDisabled, "edit")
    visit releaf_permissions_roles_path

    expect(page.status_code).to eq(403)
    within "main" do
      expect(page).to have_text("edit feature disabled for roles")
    end
  end

  it "returns 403 status code and generic error page for restricted content" do
    allow_any_instance_of(Releaf::Permissions::AccessControl).to receive(:controller_permitted?).and_return(false)
    visit releaf_permissions_roles_path

    expect(page.status_code).to eq(403)
    within "main" do
      expect(page).to have_text("You are not authorized to access roles")
    end
  end
end
