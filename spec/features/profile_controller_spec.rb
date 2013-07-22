require 'spec_helper'
describe Releaf::ProfileController do
  before do
    auth_as_admin
    @admin = Releaf::Admin.last
  end

  it "update current user profile with new values", :js => true do
    visit releaf_profile_path

    within("form.edit_resource") do
      fill_in 'Name',    :with => "Will"
      fill_in 'Surname', :with => "Smith"
      fill_in 'Email', :with => "will@example.com"
      select 'lv', :from => 'Locale'
    end
    click_button 'Save'

    expect(page).to have_content 'Updated'
    expect(find_field('Name').value).to eq('Will')
    expect(find_field('Surname').value).to eq('Smith')
    expect(find_field('Email').value).to eq('will@example.com')
    expect(find_field('Locale').value).to eq('lv')
  end

  it "update user password", :js => true do
    visit releaf_profile_path

    within("form.edit_resource") do
      fill_in 'Password', :with => "newpassword123", :match => :prefer_exact
      fill_in 'Password confirmation', :with => "newpassword123", :match => :prefer_exact
    end
    click_button 'Save'

    expect(page).to have_content 'Updated'
    find('header > ul > li.sign-out > form > button').click
    expect(page).to have_content 'Welcome to re:Leaf'

    visit "/admin"
    within("form.login") do
      fill_in 'Email',    :with => @admin.email
      fill_in 'Password', :with => "newpassword123"
    end
    click_button 'Sign in'
    expect(page).to have_css('header > ul > li.sign-out > form > button')
  end

  it "do not update user role", :js => true do
    content_role = FactoryGirl.create(:content_role)

    visit releaf_profile_path
    # inject role_id to profile form
    inject_script = 'jQuery("form.edit_resource").append(\'<input type="text" name="resource[role_id]" value="' + content_role.id.to_s + '" />\');'
    page.evaluate_script(inject_script)
    click_button 'Save'

    expect(page).to have_content 'Updated'
    expect(page).to have_content 'Permissions'
  end
end
