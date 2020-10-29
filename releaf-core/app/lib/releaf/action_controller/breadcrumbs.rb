module Releaf::ActionController::Breadcrumbs
  extend ActiveSupport::Concern

  included do
    before_action :build_breadcrumbs
  end

  def build_breadcrumbs
    @breadcrumbs = [controller_breadcrumb].compact
  end

  def controller_breadcrumb
    {name: definition.localized_name, url: definition.path} if definition
  end

  def add_resource_breadcrumb(resource, url = nil)
    if resource.new_record?
      name=  I18n.t('New record', scope: 'admin.breadcrumbs')
      url = url_for(action: :new, only_path: true) if url.nil?
    else
      url_action = feature_available?(:show) ? :show : :edit
      name = Releaf::ResourceBase.title(resource)
      url = url_for(action: url_action, id: resource.id, only_path: true) if url.nil?
    end
    @breadcrumbs << { name: name, url: url }
  end
end
