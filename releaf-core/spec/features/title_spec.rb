require 'rails_helper'
feature "Controller title" do
  scenario "shows only application title" do
    visit releaf_root_path
    expect(page.title).to eq("Dummy")
  end

  scenario "shows only controller and application title" do
    auth_as_user
    visit releaf_permissions_user_profile_path
    expect(page.title).to eq("Releaf/permissions/profile - Dummy")
  end
end
