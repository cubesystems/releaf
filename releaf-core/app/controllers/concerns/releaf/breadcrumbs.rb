module Releaf
  module Breadcrumbs
    extend ActiveSupport::Concern

    included do
      before_filter :build_breadcrumbs
    end

    def build_breadcrumbs
      @breadcrumbs = [home_breadcrumb, controller_breadcrumb].compact
    end

    def home_breadcrumb
       { name: I18n.t('Home', scope: 'admin.breadcrumbs'), url: releaf_root_path }
    end

    def controller_breadcrumb
      controller_params = Releaf.controller_list[self.class.name.sub(/Controller$/, '').underscore]
      if controller_params
        {
          name: I18n.t(controller_params[:name], scope: "admin.menu_items"),
          url: send("#{controller_params[:url_helper]}_path")
        }
      end
    end

    def add_resource_breadcrumb resource, url = nil
      if resource.new_record?
        name=  I18n.t('New record', scope: 'admin.breadcrumbs')
        url = url_for(action: :new, only_path: true) if url.nil?
      else
        if resource.respond_to?(:to_text)
          name = resource.send(:to_text)
        else
          name = I18n.t('Edit record', scope: 'admin.breadcrumbs')
        end
        url = url_for(action: :edit, id: resource.id, only_path: true) if url.nil?
      end
      @breadcrumbs << { name: name, url: url }
    end
  end
end
