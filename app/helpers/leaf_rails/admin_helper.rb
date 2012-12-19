module LeafRails
  module AdminHelper

    def menu
      menu = {
        :items => {
          "leaf_rails/content"  => 'Content',
          "admin/home"          => 'Modules',
          "leaf_rails/aliases"  => 'Aliases'
         },
        :active => "admin/home",
      }

      if menu[:items].include?( params[:controller] )
        menu[:active] = params[:controller]
      end

      return menu
    end

  end
end
