require 'spec_helper'
feature "Roles management", js: true do
  background do
    auth_as_admin
    @role = Releaf::Role.first
  end

  scenario "create new role" do
    visit releaf_roles_path
    click_link "Create new item"
    within("form.new_resource") do
      fill_in("Name", :with => "second role")
      click_button 'Save'
    end

    expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: "Created")
  end

  scenario "update existing role" do
    visit releaf_roles_path
    click_link @role.name
    within("form.edit_resource") do
      fill_in("Name", :with => "new name")
      click_button 'Save'
    end

    expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: "Updated")
  end

  scenario "change role default controller" do
    visit releaf_roles_path
    click_link @role.name
    within("form.edit_resource") do
      select('Admin/books', :from => 'Default controller')
      click_button 'Save'
    end

    expect(page).to have_select('Default controller', selected: 'Admin/books')
  end

  scenario "change role controller permissions" do
    visit releaf_roles_path
    click_link @role.name
    within("form.edit_resource") do
      uncheck('Admin/books')
      click_button 'Save'
    end

    Releaf.available_admin_controllers.each do |controller|
      if controller == "admin/books"
        expect(page).to have_unchecked_field(I18n.t(controller, :scope => 'admin.menu_items'))
      else
        expect(page).to have_checked_field(I18n.t(controller, :scope => 'admin.menu_items'))
      end
    end
  end
end
