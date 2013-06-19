module Releaf
  module AdminHelper

    def admin_main_menu
      items = []

      user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")

      Releaf.menu.each do |menu_item|
        if menu_item.has_key? :items
          item = {
            :name => menu_item[:name],
            :active => false
          }

          submenu_items = []
          menu_item[:items].each do |submenu_item|
            if user.role.authorize!(submenu_item[:controller])
              submenu_item2 = get_releaf_menu_item(submenu_item)

              # use first available controller url
              unless item.has_key? :url
                item[:url] = submenu_item2[:url]
              end
              submenu_items << submenu_item2
            end
          end

          item[:items] = submenu_items
          items << item if item.has_key? :url

        elsif user.role.authorize!(menu_item[:controller])
          item = get_releaf_menu_item(menu_item)
          if menu_item[:controller] == params[:controller]
            item[:active] = true
          end

          items << item
        end
      end

      return items
    end

    def get_releaf_menu_item item
      {
        :name => item[:name],
        :url => send(item[:url_helper]),
        :active => (item[:controller] == params[:controller])
      }
    end

  end
end
