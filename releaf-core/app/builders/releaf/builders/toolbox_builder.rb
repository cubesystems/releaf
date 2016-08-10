class Releaf::Builders::ToolboxBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template
  include Releaf::Builders::Resource

  def output
    safe_join do
      items.map do |item|
        tag('li', item)
      end
    end
  end

  def items
    list = []
    list << destroy_confirmation_link if feature_available? :destroy
    list
  end

  def destroy_confirmation_link
    button(t("Delete"), nil, class: %w(ajaxbox danger), href: destroy_confirmation_url, data: {modal: true})
  end

  def destroy_confirmation_url
     url_for(action: :confirm_destroy, id: resource.id, index_path: index_path)
  end
end
