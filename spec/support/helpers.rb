module Helpers
  def auth_as_user full_login = false, factory = :user
    if factory.is_a? Releaf::Permissions::User
      user = factory
    else
      user = FactoryGirl.create(factory)
    end
    if full_login
      visit "/"
      within("form.login") do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
      end

      click_button 'Sign in'
    else
      login_as user
    end

    return user
  end

  def save_and_check_response status_text
    click_button 'Save'
    expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: status_text)
  end

  # As there is no visual UI for settings update being successful
  # do check against database
  def wait_for_settings_update key, value = true
    safety = 5
    while !(@user.settings.try(:[], key) == value) && (safety > 0)
      safety -= 1
      sleep 0.5
    end
  end

  def open_toolbox_dialog item_name, resource = nil
    open_toolbox(item_name, resource)
    expect(page).to have_css('.dialog form[data-validation="true"][data-validation-initialized="true"]')
  end

  def open_toolbox item_name, resource = nil, content_controller = false
    if resource
      if content_controller
        find('.view-index .collection .row[data-id="' + resource.id.to_s  + '"] .toolbox button.trigger').click
      else
        find('.view-index .table tr[data-id="' + resource.id.to_s  + '"] .toolbox button.trigger').click
      end
    else
      find('.main h2.header .toolbox-wrap .toolbox button.trigger').click
    end

    click_link item_name
  end

  def fill_in_richtext html_element_id, content
    expect(page).to have_css("##{html_element_id}.ckeditor-initialized", visible: false) # wait for ckeditor appearance
    page.execute_script("$('##{html_element_id}').val(\"#{content}\")")
  end
end
