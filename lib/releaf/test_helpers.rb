module Releaf
  # Releaf::TestHelpers provides a facility to simplify admin functionality testing
  module TestHelpers
    def auth_as_user(full_login = false, factory = :user)
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

    def stub_settings(values)
      unless @releaf_settings_default_stubbed
        allow(Releaf::Settings).to receive(:[]).and_call_original
        @releaf_settings_default_stubbed = true
      end

      values.each_pair do|key, value|
        allow(Releaf::Settings).to receive(:[]).with(key).and_return(value)
      end
    end

    def update_resource(&block)
      within "form.edit-resource" do
        yield
      end
      save_and_check_response "Update succeeded"
    end

    def create_resource(&block)
      click_link "Create new resource" unless first("form.new-resource")
      within "form.new-resource" do
        yield
      end
      save_and_check_response "Create succeeded"
    end

    def within_search(&block)
      within("form.search") do
        yield
      end
    end

    def search(text)
      within_search do
        fill_in 'search', with: text
      end
    end

    def within_dialog(&block)
      within(".dialog.initialized") do
        yield
      end
    end

    def close_dialog
      within_dialog do
        find("a[data-type='cancel']").click
      end
      expect(page).to have_no_css(".dialog")
    end

    def save_and_check_response(status_text)
      click_button 'Save'
      expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: status_text)
    end

    # As there is no visual UI for settings update being successful
    # do check against database
    def wait_for_settings_update(key, value = true)
      safety = 5
      while !(@user.settings.try(:[], key) == value) && (safety > 0)
        safety -= 1
        sleep 0.5
      end
    end

    def open_toolbox_dialog(item_name, resource = nil, resource_selector_scope = ".view-index .table tr")
      open_toolbox(item_name, resource, resource_selector_scope)
      expect(page).to have_css('.dialog.initialized')
    end

    def open_toolbox(item_name, resource = nil, resource_selector_scope = ".view-index .table tr")
      if resource
        find(resource_selector_scope + '[data-id="' + resource.id.to_s  + '"] .toolbox button.trigger').click
      else
        find('main section header .toolbox-wrap .toolbox button.trigger').click
      end

      click_link item_name
    end

    def fill_in_richtext(html_element_id, content)
      expect(page).to have_css("##{html_element_id}.ckeditor-initialized", visible: false) # wait for ckeditor appearance
      page.execute_script("$('##{html_element_id}').val(\"#{content}\")")
    end
  end
end
