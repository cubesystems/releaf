require 'spec_helper'
describe "home page" do
  it "displays the user's username after successful login" do
    Releaf::Role.create!({
    name:     'admins',
    default:  false,
    admin_permission: true
    })

      Releaf::Admin.create!({
      name: 'Admin',
      surname: 'User',
      password: 'password',
      password_confirmation: 'password',
      email: 'admin@example.com',
      role_id: Releaf::Role.first.id
    })

    get "/admin/sign_in"
    assert_select "form.login_form" do
      assert_select "input[id=?]", "releaf_admin_email"
      assert_select "input[id=?]", "releaf_admin_password"
      assert_select "button[type=?]", "submit"
    end

    post "/admin/sign_in", :releaf_admin => {:email => "admin@example.com", :password => "password"}
    assert_select ".main_menu"
  end
end
