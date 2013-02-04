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

  it "displays the user's username after successful login" do

    visit "/admin"
    within("form.login_form") do
      fill_in 'releaf_admin_email',    :with => 'admin@example.com'
      fill_in 'releaf_admin_password', :with => 'password'
    end
    click_button 'Sign in'
    page.should have_content 'Logout'
  end
end
