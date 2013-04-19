module Releaf
  module AdminHelper

    def admin_main_menu
      items = []

      user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")

      Releaf.menu.each do |menu_item|
        if menu_item.has_key? :sections
          item = {
            :name => menu_item[:name],
            :active => false
          }

          menu_item[:sections].each do |menu_section|
            menu_section[:items].each do |submenu_item|
              if user.role.authorize!(submenu_item[:controller])

                if submenu_item[:controller] == params[:controller]
                  item[:active] = true
                end

                # use first available controller url
                unless item.has_key? :url
                  item[:url] = get_releaf_menu_item(submenu_item)[:url]
                end
              end
            end
          end

          items << item if item.has_key? :url

        elsif user.role.authorize!(menu_item[:controller])
          items << get_releaf_menu_item(menu_item)
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
