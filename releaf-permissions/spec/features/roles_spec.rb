require 'spec_helper'
feature "Roles management", js: true do
  background do
    auth_as_admin
    @role = Releaf::Role.first
  end

  scenario "User creates a new role" do
    visit releaf_roles_path
    click_link "Create new item"
    fill_in("Name", with: "second role")
    save_and_check_response('Created')
  end

  scenario "User updates an existing role" do
    visit releaf_roles_path
    click_link @role.name
    fill_in("Name", with: "new name")
    save_and_check_response('Updated')
  end

  scenario "User changes the default controller of a role" do
    visit releaf_roles_path
    click_link @role.name
    select('Admin/books', from: 'Default controller')
    save_and_check_response('Updated')

    expect(page).to have_select('Default controller', selected: 'Admin/books')
  end

  scenario "User changes permissions of a role controller" do
    visit releaf_roles_path
    click_link @role.name
    uncheck('Admin/books')
    save_and_check_response('Updated')

    Releaf.available_controllers.each do |controller|
      if controller == "admin/books"
        expect(page).to have_unchecked_field(I18n.t(controller, scope: 'admin.menu_items'))
      else
        expect(page).to have_checked_field(I18n.t(controller, scope: 'admin.menu_items'))
      end
    end
  end
end
