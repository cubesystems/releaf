module Helpers
  def auth_as_admin full_login = false, factory = :admin
    if factory.is_a? Releaf::Admin
      admin = factory
    else
      admin = FactoryGirl.create(factory)
    end
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
