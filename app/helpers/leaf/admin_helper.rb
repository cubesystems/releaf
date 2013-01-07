module Leaf
  module AdminHelper

    def menu
      menu = {
        :items => {
          "leaf/content"  => 'Content',
          "admin/home"          => 'Modules',
          "leaf/aliases"  => 'Aliases'
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
