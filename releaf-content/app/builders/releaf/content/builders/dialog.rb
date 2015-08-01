module Releaf::Content::Builders
  module Dialog
    include Releaf::Builders::ResourceDialog
    include Releaf::Builders::Collection
    include Releaf::Content::Builders::Tree

    def footer_primary_tools
      [cancel_button]
    end

    def cancel_button
      button(t('Cancel'), "ban", class: "secondary", data: {type: 'cancel'}, href: url_for( action: 'index' ))
    end
  end
end
