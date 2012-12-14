module LeafRails
  module AdminHelper

    def menu
      menu = {
        :items => ["content", "admins", "aliases"],
        :active => "admins",
      }

      if menu[:items].include?( params[:controller].split('/').pop() )
        menu[:active] = params[:controller].split('/').pop()
      end

      return menu
    end

  end
end
