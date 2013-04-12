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
          is_any_controller_available = false

          menu_item[:sections].each do |menu_section|
            menu_section[:items].each do |submenu_item|
              if user.role.authorize!(submenu_item[:controller])
                is_any_controller_available = true

                if submenu_item[:controller] == params[:controller]
                  item[:active] = true
                end

                unless item.has_key? :url
                  if submenu_item.has_key? :helper
                    item[:url] = send(submenu_item[:helper] + "_path")
                  else
                    item[:url] = url_for(:controller => submenu_item[:controller])
                  end
                end
              end
            end
          end

          items << item if is_any_controller_available

        elsif user.role.authorize!(menu_item[:controller])
          items << get_releaf_menu_item(menu_item)
        end
      end

      return items
    end

    def get_releaf_menu_item item
        if item.has_key? :helper 
          url = send(item[:helper] + "_path")
        else
          url = url_for(:controller => item[:controller])
        end

        {
          :name => item[:controller],
          :url => url,
          :active => item[:controller] == params[:controller]
        }
    end

  end
end
