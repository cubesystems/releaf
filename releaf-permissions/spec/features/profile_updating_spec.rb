require 'spec_helper'
feature "Admin user update profile" do
  background do
    auth_as_admin(false, FactoryGirl.create(:admin, email: "email@example.com"))
    visit releaf_permissions_admin_profile_path
  end

  scenario "name, surname and locale" do
    fill_in 'Name',    :with => "Edward"
    fill_in 'Surname', :with => "Bat"
    select "lv", :from => "Locale"
    click_button 'Save'

    expect(page).to have_css('header .profile .name', text: "Edward Bat")
  end

  scenario "password and email" do
    # update
    fill_in 'Email', :with => "new.email@example.com"
    fill_in 'Password', :with => "newpassword123", :match => :prefer_exact
    fill_in 'Password confirmation', :with => "newpassword123", :match => :prefer_exact
    click_button 'Save'

    # logout
    find('header > ul > li.sign-out > form > button').click

    # login
    visit releaf_root_path
    fill_in 'Email',    :with => "new.email@example.com"
    fill_in 'Password', :with => "newpassword123"
    click_button 'Sign in'

    expect(page).to have_css('.sign-out')
  end
end
