require 'spec_helper'
feature "Controller title" do
  scenario "shows only application title" do
    visit releaf_root_path
    expect(page.title).to eq("Dummy")
  end

  scenario "shows only controller and application title" do
    auth_as_admin
    visit releaf_admin_profile_path
    expect(page.title).to eq("Releaf/admin profile - Dummy")
  end
end
