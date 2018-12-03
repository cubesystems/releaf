module Admin::Banners
  class ShowBuilder < Releaf::Builders::ShowBuilder
    def section_body
      render "content"
    end
  end
end
