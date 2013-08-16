module Helpers
  def auth_as_admin full_login = false, factory = :admin
    admin = FactoryGirl.create(factory)
    if full_login
      visit "/"
      within("form.login") do
        fill_in 'Email',    :with => admin.email
        fill_in 'Password', :with => admin.password
      end

      click_button 'Sign in'
    else
      login_as admin
    end

    return admin
  end
end
