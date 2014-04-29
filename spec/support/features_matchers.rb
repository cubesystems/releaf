module Capybara
  class Session
    def has_number_of_resources?(count)
      has_css?('.header .totals', text: "#{count} Resources found")
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
