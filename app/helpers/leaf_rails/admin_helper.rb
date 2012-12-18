module LeafRails
  module AdminHelper

    def menu
      menu = {
        :items => ["leaf_rails/content", "admin/admins", "leaf_rails/aliases"],
        :active => "admins",
      }

      if menu[:items].include?( params[:controller] )
        menu[:active] = params[:controller]
      end

      return menu
    end

  end
end
