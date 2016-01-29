module Releaf::Builders::Page
  class HeaderBuilder
    include Releaf::Builders::Base
    include Releaf::Builders::Template

    def output
      safe_join do
        items
      end
    end

    def items
      [home_link]
    end

    def home_link
      tag(:a, class: "home", href: home_url) do
        image_tag(home_image_path, alt: home_text)
      end
    end

    def home_url
      url_for(:releaf_root)
    end

    def home_text
      "Releaf"
    end

    def home_image_path
      "releaf/logo.png"
    end
  end
end
