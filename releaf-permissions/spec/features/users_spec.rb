require 'rails_helper'
feature "Users", js: true do
  let!(:user){ create(:user, email: "admin@example.com") }
  let!(:simple_user){ create(:content_user, email: "simple@example.com") }

  describe "users CRUD" do
    background do
      visit "/admin"
      within("form.login") do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
      end
      click_button 'Sign in'
      expect(page).to have_css('body > header form.sign-out button')
    end

    scenario "new user creation", js: true do
      visit releaf_permissions_users_path
      create_resource do
        fill_in 'Name', with: "John"
        fill_in 'Surname', with: "Appleseed"
        fill_in 'Email', with: "john@example.com"
        fill_in 'Password', with: "password", match: :prefer_exact
        fill_in 'Password confirmation', with: "password", match: :prefer_exact

        expect(page).to have_select('Locale', options: ["", "En", "Lv"])
        select 'En', from: 'Locale'
      end

      expect(page).to have_content 'John Appleseed'
      visit '/admin/users'
      expect(page).to have_content 'john@example.com'

      visit (releaf_permissions_users_path)
      open_toolbox_dialog("Delete", Releaf::Permissions::User.last)
      click_button 'Yes'
      expect(page).not_to have_content 'john@example.com'
    end

    scenario "user search" do
      visit '/admin/users'
      expect(page).to have_content 'simple@example.com'
      search "admin@example.com"
      expect(page).not_to have_content 'simple@example.com'
    end
  end

  describe "login as user procedure" do
    background do
      visit "/admin"
      within("form.login") do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
      end
      click_button 'Sign in'
    end

    scenario "user page content" do
      expect(page).to have_css('body > header form.sign-out button')
      expect(page).to have_content 'Admin/nodes'
      expect(page).to have_content 'Permissions'
      expect(page).to have_content 'Releaf/i18n database/translations'
      # admin/users index view
      expect(page).to have_content 'admin@example.com'
      expect(page).to have_content 'simple@example.com'
    end

    scenario "logout sequence" do
      find('body > header form.sign-out button').click

      expect(page).to have_content 'Welcome to Releaf'

      visit "/admin"
      expect(page).to have_content 'Sign in'
    end
  end

  describe "login as simple user procedure" do
    background do
      visit "/admin"
      within("form.login") do
        fill_in 'Email', with: simple_user.email
        fill_in 'Password', with: simple_user.password
      end
      click_button 'Sign in'
    end

    scenario "user page content" do
      expect(page).to have_css('body > header form.sign-out button')
      expect(page).to have_content 'Admin/nodes'
    end

    scenario "translations module access denied" do
      visit "/admin/translations"
      expect(page).to have_content 'You are not authorized to access translations'
    end

    scenario "logout sequence" do
      find('body > header form.sign-out button').click

      expect(page).to have_content 'Welcome to Releaf'

      visit "/admin"
      expect(page).to have_content 'Sign in'
    end
  end
end
