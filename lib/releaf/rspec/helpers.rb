module Releaf::Test
  # Releaf::TestHelpers provides a facility to simplify admin functionality testing
  module Helpers
    def postgresql?
      adapter_name == 'PostgreSQL'
    end

    def mysql?
      adapter_name == "Mysql2"
    end

    def adapter_name
      ActiveRecord::Base.connection.adapter_name
    end

    def auth_as_user(full_login = false, factory_or_instance = :user)
      if factory_or_instance.is_a?(Symbol) || factory_or_instance.is_a?(String)
        user = create(factory_or_instance)
      else
        user = factory_or_instance
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

      user
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

    def update_resource
      within "form.edit-resource" do
        yield
      end
      save_and_check_response "Update succeeded"
    end

    def create_resource
      click_link "Create new resource" unless first("form.new-resource")
      within "form.new-resource" do
        yield
      end
      save_and_check_response "Create succeeded"
    end

    def within_search
      within("form.search") do
        yield
      end
    end

    def search(text)
      within_search do
        fill_in 'search', with: text
      end
    end

    def within_dialog
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

    def wait_for_all_richtexts
      # wait for all ckeditors to fully initialize before moving on.
      # otherwise the page sometimes produces random js errors in fast tests
      number_of_normal_richtexts = page.all('.field.type-richtext:not(.i18n)').length
      number_of_localized_richtexts = page.all('.field.type-richtext.i18n .localization', visible: false).length
      number_of_richtexts = number_of_normal_richtexts + number_of_localized_richtexts
      if (number_of_richtexts > 0)
        expect(page).to have_css(".ckeditor-initialized", visible: false, count: number_of_richtexts)
      end
    end

    def switch_admin_locale(locale)
      switch = page.first('.localization-switch')

      current_locale = switch.text.downcase
      new_locale     = locale.to_s.downcase

      if current_locale == new_locale
        return current_locale
      end

      within( switch ) do
        click_button current_locale
      end

      menu = page.find(:xpath, '/html//menu[@class="localization-menu-items"]')
      within( menu ) do
        click_button new_locale.capitalize
      end

      wait_for_all_richtexts
    end

    def save_and_check_response(status_text)
      wait_for_all_richtexts
      click_button 'Save'
      expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: status_text)
      wait_for_all_richtexts
    end

    # As there is no visual UI for settings update being successful
    # do check against database
    def wait_for_settings_update(key, value = true)
      safety = 5
      loop do
        if @user.settings.try(:[], key) == value
          return
        elsif safety > 0
          safety -= 1
          sleep 0.5
        else
          fail "'#{key}' setting didn't change to '#{value}' (#{value.class.name})"
        end
      end
    end

    def open_toolbox_dialog(item_name, resource = nil, resource_selector_scope = ".view-index .table tr")
      open_toolbox(item_name, resource, resource_selector_scope)
      expect(page).to have_css('.dialog.initialized')
    end

    def open_toolbox(item_name, resource = nil, resource_selector_scope = ".view-index .table tr")
      if resource
        find(resource_selector_scope + '[data-id="' + resource.id.to_s  + '"] .toolbox.initialized button.trigger').click
      else
        find('main section header .toolbox-wrap .toolbox.initialized button.trigger').click
      end

      within('menu.toolbox-items') do
        click_on(item_name)
      end
    end

    def fill_in_date(field_locator, options)
      date = options[:with]

      if date.is_a? Time
        date = date.to_date
      elsif date.is_a? Date
        # do nothing
      else
        # try to convert it to string
        date = Date.parse(date.to_s)
      end

      # wrapper = find('.field.type-date')
      field = find_field( field_locator )
      field_id = field[:id]

      if Capybara.current_driver == Capybara.javascript_driver
        execute_script('$("#' + field_id + '").trigger("focus")')

        expect(page.document).to have_css('.ui-datepicker-year')
        expect(page.document).to have_css('.ui-datepicker-month')

        year_string = date.year.to_s
        execute_script('$(".ui-datepicker-year").val(' + year_string + ').change()')
        expect(evaluate_script('$(".ui-datepicker-year").val();')).to eq year_string

        month_string = (date.month - 1).to_s
        execute_script('$(".ui-datepicker-month").val("' + month_string + '").change()')
        expect(evaluate_script('$(".ui-datepicker-month").val();')).to eq month_string

        execute_script('$("a.ui-state-default:contains(' + date.day.to_s + ')").filter(function() { return $(this).text() == "' + date.day.to_s +  '"}).trigger("click")')

        expect(page.document).to have_no_css('.ui-datepicker-year')
      else
        fill_in field_locator, with: date.to_s
      end

    end

    def fill_in_richtext(locator, options = {} )
      # locator can be anything that is normally accepted by fill_in
      # e.g., the label text or the id of the textarea

      expect(page).to have_css('.field.type-richtext label')

      # locate possibly hidden textarea among active/visible richtext fields ignoring hidden localization versions
      textareas = []
      richtext_boxes = all(".field.type-richtext:not(.i18n), .field.type-richtext.i18n .localization.active")
      richtext_boxes.each do |richtext_box|
        textarea = richtext_box.first(:field, locator, visible: false)
        textareas << textarea if textarea.present?
      end

      if textareas.count > 1
        raise Capybara::Ambiguous.new("Ambiguous match, found #{target_textareas.count} richtext boxes matching #{locator}")
      elsif textareas.count < 1
        raise Capybara::ElementNotFound.new("Unable to find richtext box #{locator}")
      end

      textarea_id = textareas.first[:id].to_s
      expect(page).to have_css("##{textarea_id}.ckeditor-initialized", visible: false) # wait for ckeditor appearance
      html = options[:with].to_s
      page.execute_script("CKEDITOR.instances['#{textarea_id}'].setData(#{html.to_json});")
    end


    def scroll_to_bottom_of_page
      execute_script('window.scrollTo(0, document.body.scrollHeight);')
    end

    def add_nested_item(block_name, expected_item_index)
      scroll_to_bottom_of_page
      all('button', text: 'Add item').last.click  # use last button in case of multiple nested items
      wait_for_nested_item block_name, expected_item_index

      if block_given?
        within(".item[data-name=\"#{block_name}\"][data-index=\"#{expected_item_index}\"]") do
          yield
        end
      end
    end

    def remove_nested_item(block_name, item_index)
      base_selector = ".item[data-name=\"#{block_name}\"][data-index=\"#{item_index}\"]"
      page.find("#{base_selector} > .remove-item-box button.remove-nested-item").click
      # wait for js to finish hiding the block
      # the opacity and display styles may get set in different order, so select both orders
      expect(page).to have_css("#{base_selector}[style=\"display: none; opacity: 0;\"], #{base_selector}[style=\"opacity: 0; display: none;\"]", visible: false)
    end

    def wait_for_nested_item(block_name, item_index)
      # wait for js to finish initializing the block
      expect(page).to have_css(".item[data-name=\"#{block_name}\"][data-index=\"#{item_index}\"][style=\"opacity: 1; display: block;\"]")
    end

  end
end
