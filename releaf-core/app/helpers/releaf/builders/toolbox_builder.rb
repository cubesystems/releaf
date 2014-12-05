class Releaf::Builders::ToolboxBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template
  include Releaf::Builders::ResourceToolbox

  def items
    list = []
    list << destroy_item if feature_available? :destroy
    list
  end

  def destroy_item
    button(t('Delete', scope: 'admin.global'), "trash-o lg", class: %w(ajaxbox danger), href: url_for( action: :confirm_destroy, id: resource.id, index_url: index_url), data: {modal: true})
  end

end