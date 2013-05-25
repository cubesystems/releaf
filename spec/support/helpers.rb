module Helpers
  def auth_as_admin full_login = false
    if full_login
      admin = create(:admin)
      visit "/"
      within("form.login_form") do
        fill_in 'Email',    :with => admin.email
        fill_in 'Password', :with => admin.password
      end
      click_button 'Sign in'
    else
      admin = FactoryGirl.create(:admin)
      login_as admin
    end
  end
end
