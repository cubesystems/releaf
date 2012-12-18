module LeafRails
  module AdminHelper

    def menu
      menu = {
        :items => ["leaf_rails/content", "admins", "leaf_rails/aliases"],
        :active => "admins",
      }

      if menu[:items].include?( params[:controller].split('/').pop() )
        menu[:active] = params[:controller].split('/').pop()
      end

      return menu
    end

  end
end
