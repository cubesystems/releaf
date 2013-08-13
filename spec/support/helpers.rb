module Helpers
  def auth_as_admin full_login = false
    if full_login
      admin = create(:admin)
      visit "/"
      within("form.login") do
        fill_in 'Email',    :with => admin.email
        fill_in 'Password', :with => admin.password
      end
      click_button 'Sign in'
    else
      admin = FactoryGirl.create(:admin)
      login_as admin
    end
  end

  def wait_for_ajax_to_complete
    # pass timeout in seconds if you need to override default_wait_time
    page.wait_until { page.evaluate_script('jQuery.active === 0') }
  end
end
