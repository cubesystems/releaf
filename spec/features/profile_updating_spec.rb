require 'spec_helper'
feature "Admin user update profile" do
  background do
    auth_as_admin(false, FactoryGirl.create(:admin, email: "email@example.com"))
    visit releaf_admin_profile_path
  end

  scenario "for all data, except password" do
    fill_in 'Name',    :with => "Will"
    fill_in 'Surname', :with => "Smith"
    fill_in 'Email', :with => "will@example.com"
    select 'lv', :from => 'Locale'
    click_button 'Save'

    expect(find_field('Name').value).to eq('Will')
    expect(find_field('Surname').value).to eq('Smith')
    expect(find_field('Email').value).to eq('will@example.com')
    expect(find_field('Locale').value).to eq('lv')
  end

  scenario "password" do
    # update
    fill_in 'Password', :with => "newpassword123", :match => :prefer_exact
    fill_in 'Password confirmation', :with => "newpassword123", :match => :prefer_exact
    click_button 'Save'

    # logout
    find('header > ul > li.sign-out > form > button').click

    # login
    visit releaf_root_path
    fill_in 'Email',    :with => "email@example.com"
    fill_in 'Password', :with => "newpassword123"
    click_button 'Sign in'

    expect(page).to have_css('.sign-out')
  end
end
