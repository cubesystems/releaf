module Capybara
  class Session

    def primary_header_css_rule
      "main > section header"
    end

    def has_cells_text?(cells, options = {})
      cells_count = cells.count
      cells_count += 1 if options.fetch(:with_toolbox, true)
      type = options.fetch(:type, "td")
      has_selector?(type, count: cells_count) && has_text?(cells.join(""))
    end

    def has_header?(*args)
      has_css?("#{primary_header_css_rule} h1", *args)
    end

    def has_no_header?(*args)
      has_no_css?("#{primary_header_css_rule} h1", *args)
    end


    def has_number_of_resources?(count)
      has_css?("#{primary_header_css_rule} .totals", text: "#{count} resources found")
    end


    # Allows to match againg validation errors within forms
    # Support either model specific (base) errors with:
    #     expect(page).to have_error('Global form error message')
    # and attribute specific errors with:
    #     expect(page).to have_error('Taken', field: 'Lol')
    #
    # @param error_message [String] error message to find
    # @param options [Hash] available option is `field` that can be anything that is normally accepted by fill_in
    #     e.g., the label text or the id of the textarea
    # @return [true] whether errors has been found otherwise will raise Capybara::ElementNotFound exception
    def has_error?(error_message, options = {})
      error_found = false
      if options[:field]
        first('.field.has-error', minimum: 1) # wait for any errors to come from validation
        all(".field.has-error").each do |field_container|
          if !error_found
            within(field_container) do
              if has_field?(options[:field], wait: false) && has_css?(".error", text: error_message, wait: false)
                error_found = true
              end
            end
          end
        end
      else
        if first(".form-error-box .error", text: error_message)
          error_found = true
        end
      end

      unless error_found
        failure_text = "Unable to find error message #{error_message.inspect}"
        if options[:field]
          failure_text += " on field #{options[:field].inspect}"
        end
        raise Capybara::ElementNotFound.new failure_text
      end

      true
    end

    def has_breadcrumbs?(*items)
      items.each_with_index do|item, index|
        has_css?("main header nav ul.breadcrumbs li:nth-child(#{index}) a", text: item)
      end
    end

    def has_notification?(text, type="success")
      result = has_css?(".notifications .notification[data-type='#{type}']", text: text)
      if first(".notifications button.close")
        find(".notifications .notification[data-type='#{type}'] button.close").click
        has_no_css?(".notifications .notification[data-type='#{type}'] button.close")
      end

      result
    end
  end
end
