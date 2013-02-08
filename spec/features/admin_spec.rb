require 'spec_helper'
describe "home page" do
  before do
    module Leaf
    end
    @role = create(:role, :admin)
    @admin = build(:admin)
    @admin.role_id = @role.id
    @admin.save

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
      page.should have_content 'Releaf/Content'
      page.should have_content '*Permissions'
      page.should have_content 'Releaf/Translations'
    end

    it "logout sequence" do
      click_link 'Logout'

      page.should have_content 'Welcome to re:Leaf'

      visit "/admin"
      page.should have_content 'Sign in'

    end


  end
end
