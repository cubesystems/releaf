module Capybara
  class Session

    def primary_header_css_rule
      "main > section header"
    end

    def has_header?(*args)
      has_css?("#{primary_header_css_rule} h1", *args)
    end

    def has_number_of_resources?(count)
      has_css?("#{primary_header_css_rule} .totals", text: "#{count} Resources found")
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
