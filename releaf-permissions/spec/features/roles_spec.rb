require 'spec_helper'
feature "Roles management", js: true do
  background do
    auth_as_user
    @role = Releaf::Permissions::Role.first
  end

  scenario "User creates a new role" do
    visit releaf_permissions_roles_path
    click_link "Create new resource"
    create_resource do
      fill_in("Name", with: "second role")
      select('Releaf/content/nodes', from: 'Default controller')
    end
    visit releaf_permissions_roles_path
    expect(page).to have_content "second role"
  end

  scenario "User updates an existing role" do
    visit releaf_permissions_roles_path
    click_link @role.name
    update_resource do
      fill_in("Name", with: "new name")
    end

    visit releaf_permissions_roles_path
    expect(page).to have_content "new name"
  end

  scenario "User changes the default controller of a role" do
    visit releaf_permissions_roles_path
    click_link @role.name
    update_resource do
      select('Admin/books', from: 'Default controller')
    end

    expect(page).to have_select('Default controller', selected: 'Admin/books')
  end

  scenario "User changes permissions of a role controller" do
    visit releaf_permissions_roles_path
    click_link @role.name
    update_resource do
      uncheck('Admin/books')
    end

    Releaf.available_controllers.each do |controller|
      if controller == "admin/books"
        expect(page).to have_unchecked_field(I18n.t(controller, scope: 'admin.menu_items'))
      else
        expect(page).to have_checked_field(I18n.t(controller, scope: 'admin.menu_items'))
      end
    end
  end
end
