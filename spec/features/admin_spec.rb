require 'spec_helper'
describe "home page" do
  # before do
  #   Releaf::Role.create!({
  #     name:     'admins',
  #     default:  false,
  #     admin_permission: true
  #   })

  #   Releaf::Admin.create!({
  #     name:     'Admin',
  #     surname:  'User',
  #     password: 'password',
  #     password_confirmation: 'password',
  #     email:    'admin@example.com',
  #     role_id:  Releaf::Role.first.id
  #   })
  # end

  it "login as admin" do
    visit "/admin"
    within("form.login_form") do
      fill_in 'Email',    :with => 'admin@example.com'
      fill_in 'Password', :with => 'password'
    end
    click_button 'Sign in'

    page.should have_content 'Logout'
    page.should have_content 'Releaf/Content'
    page.should have_content '*Permissions'
    page.should have_content 'Releaf/Translations'
  end
end
