module Releaf
  module ToolboxHelper

    def toolbox resource, params = {}
      return '' if resource.new_record?

      url = url_for(params.merge(action: "toolbox", id: resource.id, context: action_name))

      %Q{
      <div class="toolbox" data-url="#{url}">
        <button class="button trigger only-icon" type="button" title="#{t('Tools', scope: 'admin.global')}">
          <i class="fa fa-lg fa-cog"></i>
        </button>
        <menu class="block toolbox-items" type="toolbar">
          <i class="fa fa-lg fa-caret-up"></i>
          <ul class="block"></ul>
        </menu>
      </div>
      }.html_safe
    end
  end
end
