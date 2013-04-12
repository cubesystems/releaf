require 'spec_helper'
describe "home page" do
  before do
    module Leaf
    end
    @admin = build(:admin)
    @admin.email = "admin@example.com"
    @admin.save

    @simple_user = build(:content_admin)
    @simple_user.email = "simple@example.com"
    @simple_user.save
  end

  describe "admin users CRUD" do
    before do
      visit "/admin"
      within("form.login_form") do
        fill_in 'Email',    :with => @admin.email
        fill_in 'Password', :with => @admin.password
      end
      click_button 'Sign in'
    end

    it "new user creation" do
      click_link 'Permissions'
      click_link 'Releaf/admins'
      find('.create_new_item').click
      page.should have_content 'Create new resource'
      within("form.new_resource") do
        fill_in 'Name',    :with => "John"
        fill_in 'Surname', :with => "Appleseed"
        fill_in 'Email', :with => "john@example.com"
        fill_in 'Password:', :with => "password"
        fill_in 'Password confirmation', :with => "password"
      end
      click_button 'Save'
      page.should have_content 'John Appleseed'
      visit '/admin/admins'
      page.should have_content 'john@example.com'

      visit '/admin/admins'
      click_link 'john@example.com'
      click_link 'Destroy'
      page.should have_content 'Confirm destroy'
      click_button 'Yes'
      page.should_not have_content 'john@example.com'
    end

    it "user search" do
      visit '/admin/admins'
      page.should have_content 'simple@example.com'
      within("form.search_form") do
        fill_in 'search',    :with => "admin@example.com"
      end
      find('form.search_form button').click
      page.should_not have_content 'simple@example.com'
    end

    it "user deletion" do
    end
  end

  describe "login as admin procedure" do
    before do
      visit "/admin"
      within("form.login_form") do
        fill_in 'Email',    :with => @admin.email
        fill_in 'Password', :with => @admin.password
      end
      click_button 'Sign in'
    end

    it "admin page content" do
      page.should have_content 'Logout'
      page.should have_content 'Releaf/content'
      page.should have_content 'Permissions'
      page.should have_content 'Releaf/translations'
      # admin/admins index view
      page.should have_content 'admin@example.com'
      page.should have_content 'simple@example.com'
    end

    it "logout sequence" do
      click_link 'Logout'

      page.should have_content 'Welcome to re:Leaf'

      visit "/admin"
      page.should have_content 'Sign in'
    end
  end

  describe "login as simple user procedure" do
    before do
      visit "/admin"
      within("form.login_form") do
        fill_in 'Email',    :with => @simple_user.email
        fill_in 'Password', :with => @simple_user.password
      end
      click_button 'Sign in'
    end

    it "admin page content" do
      page.should have_content 'Logout'
      page.should have_content 'Releaf/content'
    end

    it "translations module access denied" do
      visit "/admin/translations"
      page.should have_content 'You are not authorized to access translations'
    end

    it "logout sequence" do
      click_link 'Logout'

      page.should have_content 'Welcome to re:Leaf'

      visit "/admin"
      page.should have_content 'Sign in'
    end
  end
end
