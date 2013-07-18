module Releaf
  module AdminHelper

    def current_admin_user
      self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
    end

    def admin_breadcrumbs resource = nil
      breadcrumbs = []
      breadcrumbs << { :name => I18n.t('Home', :scope => 'admin.breadcrumbs'), :url => releaf_root_path }

      admin_menu.each do |item|
        if item[:active]
          breadcrumbs << {:name => I18n.t(item[:name], :scope => "admin.menu_items"), :url => item[:url]}
          unless item[:items].blank?
            item[:items].each do |sub_menu_item|
              if sub_menu_item[:active]
                breadcrumbs << { :name => I18n.t(sub_menu_item[:name], :scope => "admin.menu_items"), :url => sub_menu_item[:url] }
              end
            end
          end
        end
      end

      unless resource.nil?
        if resource.new_record?
          breadcrumbs << { :name => I18n.t('New record', :scope => 'admin.breadcrumbs') }
        elsif resource.respond_to?(:to_text)
          breadcrumbs << {:name => resource.send(:to_text)}
        else
          breadcrumbs << { :name => I18n.t('Edit record', :scope => 'admin.breadcrumbs') }
        end
      end

      return breadcrumbs
    end


    def admin_menu
      items = []

      user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")

      Releaf.menu.each do |menu_item|
        if menu_item.has_key? :items
          item = {
            :name => menu_item[:name],
            :icon => menu_item[:icon],
            :collapsed => !cookies["releaf.side.opened.#{menu_item[:name]}"],
            :active => false
          }

          submenu_items = []
          menu_item[:items].each do |submenu_item|
            if user.role.authorize!(submenu_item[:controller])
              submenu_item2 = get_releaf_menu_item(submenu_item)
              if submenu_item2[:active]
                item[:active] = true
                # always expand if one if submenu items is active
                item[:collapsed] = false
              end

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
        :icon => item[:icon],
        :name => item[:name],
        :url => send(item[:url_helper]),
        :active => (item[:controller] == params[:controller])
      }
    end

  end
end
