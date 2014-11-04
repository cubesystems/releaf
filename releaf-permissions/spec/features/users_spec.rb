require 'spec_helper'
describe "home page" do
  before do
    module Leaf
    end
    @user = build(:user)
    @user.email = "admin@example.com"
    @user.save

    @simple_user = build(:content_user)
    @simple_user.email = "simple@example.com"
    @simple_user.save
  end

  describe "users CRUD" do
    before do
      visit "/admin"
      within("form.login") do
        fill_in 'Email', with: @user.email
        fill_in 'Password', with: @user.password
      end
      click_button 'Sign in'
      expect(page).to have_css('header > ul > li.sign-out > form > button')
    end

    it "new user creation", js: true do
      visit (releaf_permissions_users_path)
      click_link 'Create new resource'
      within("form.new_resource") do
        fill_in 'Name', with: "John"
        fill_in 'Surname', with: "Appleseed"
        fill_in 'Email', with: "john@example.com"
        fill_in 'Password', with: "password", match: :prefer_exact
        fill_in 'Password confirmation', with: "password", match: :prefer_exact

        expect(page).to have_select('Locale', options: [""] + Releaf.available_admin_locales)
        select 'en', from: 'Locale'
      end
      save_and_check_response('Create succeeded')
      expect(page).to have_content 'John Appleseed'
      visit '/admin/users'
      expect(page).to have_content 'john@example.com'

      visit (releaf_permissions_users_path)
      open_toolbox("Delete", Releaf::Permissions::User.last)
      click_button 'Yes'
      expect(page).not_to have_content 'john@example.com'
    end

    it "user search" do
      visit '/admin/users'
      expect(page).to have_content 'simple@example.com'
      within("form.search") do
        fill_in 'search', with: "admin@example.com"
      end
      find('form.search button').click
      expect(page).not_to have_content 'simple@example.com'
    end

    it "user deletion" do
    end
  end

  describe "login as user procedure" do
    before do
      visit "/admin"
      within("form.login") do
        fill_in 'Email', with: @user.email
        fill_in 'Password', with: @user.password
      end
      click_button 'Sign in'
    end

    it "user page content" do
      expect(page).to have_css('header > ul > li.sign-out > form > button')
      expect(page).to have_content 'Releaf/content'
      expect(page).to have_content 'Permissions'
      expect(page).to have_content 'Releaf/i18n database/translations'
      # admin/users index view
      expect(page).to have_content 'admin@example.com'
      expect(page).to have_content 'simple@example.com'
    end

    it "logout sequence" do
      find('header > ul > li.sign-out > form > button').click

      expect(page).to have_content 'Welcome to re:Leaf'

      visit "/admin"
      expect(page).to have_content 'Sign in'
    end
  end

  describe "login as simple user procedure" do
    before do
      visit "/admin"
      within("form.login") do
        fill_in 'Email', with: @simple_user.email
        fill_in 'Password', with: @simple_user.password
      end
      click_button 'Sign in'
    end

    it "user page content" do
      expect(page).to have_css('header > ul > li.sign-out > form > button')
      expect(page).to have_content 'Releaf/content'
    end

    it "translations module access denied" do
      visit "/admin/translations"
      expect(page).to have_content 'You are not authorized to access translations'
    end

    it "logout sequence" do
      find('header > ul > li.sign-out > form > button').click

      expect(page).to have_content 'Welcome to re:Leaf'

      visit "/admin"
      expect(page).to have_content 'Sign in'
    end
  end
end
