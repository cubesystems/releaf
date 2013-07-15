require 'spec_helper'

describe Releaf::RolesController do
  before do
    auth_as_admin
    @role = Releaf::Role.first
  end

  it "should test roles custom fields and methods" do
    # index should contain only one role
    visit admin_roles_path
    page.should have_css('.main > .table > tbody .row', :count => 1)

    # save new item and redirect to show view
    click_link "Create new item"
    within("form.new_resource") do
      page.should have_select('Default controller', :options => Releaf.available_admin_controllers.map{|controller|  I18n.t(controller, :scope => 'admin.menu_items')})
      fill_in("Name", :with => "second role")
      select(I18n.t("admin/books", :scope => 'admin.menu_items'), :from => 'Default controller')
      check(I18n.t("admin/books", :scope => 'admin.menu_items'))
      click_button 'Save'
    end
    new_role = Releaf::Role.last
    current_path.should eq(edit_admin_role_path(new_role))

    # edit view should contain all saved variables
    page.should have_css('.main h2.header', :text => "second role")
    within("form.edit_resource") do
      page.should have_select('Default controller', :selected => I18n.t(new_role.default_controller, :scope => 'admin.menu_items'))
      Releaf.available_admin_controllers.each do |controller|
        if controller == "admin/books"
          page.should have_checked_field(I18n.t(controller, :scope => 'admin.menu_items'))
        else
          page.should have_unchecked_field(I18n.t(controller, :scope => 'admin.menu_items'))
        end
      end
    end

    # index should contain two roles
    visit admin_roles_path
    page.should have_css('.main > .table > tbody .row', :count => 2)
    page.should have_css('.main > .table > tbody .row[data-id="' + new_role.id.to_s  + '"] a:last', :text => I18n.t(new_role.default_controller, :scope => 'admin.menu_items'))

  end
end
