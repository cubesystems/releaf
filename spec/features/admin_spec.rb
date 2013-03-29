require 'spec_helper'
describe "home page" do
  before do
    module Leaf
    end
    @admin_role = create(:role, :admin)
    @admin = build(:admin)
    @admin.role_id = @admin_role.id
    @admin.save

    @simple_user_role = create(:role, :content_only)
    @simple_user = build(:admin)
    @simple_user.role_id = @simple_user_role.id
    @simple_user.save
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
      page.should have_content '*permissions'
      page.should have_content 'Releaf/translations'
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
