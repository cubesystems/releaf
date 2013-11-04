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
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: admin.password
      end

      click_button 'Sign in'
    else
      login_as admin
    end

    return admin
  end

  def save_and_check_response status_text
    click_button 'Save'
    expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: status_text)
  end

  # As there is no visual UI for settings update being successful
  # do check against database
  def wait_for_settings_update key, value = true
    safety = 5
    while !(@admin.settings.try(:[], key) == value) && (safety > 0)
      safety -= 1
      sleep 0.5
    end
  end
end
