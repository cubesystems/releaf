module Releaf
  module AdminHelper

    def is_this_main_menu_item_active? releaf_main_menu_item
      _check_if_this_is_valid_releaf_main_menu_item releaf_main_menu_item

      unless releaf_main_menu_item.start_with?('*')
        return params[:controller] == _menu_item_controller_name(releaf_main_menu_item)
      else
        return base_menu_items(releaf_main_menu_item).include? params[:controller]
      end
    end

    def main_menu_item_url releaf_main_menu_item, options={}
      # TODO implement options
      _check_if_this_is_valid_releaf_main_menu_item releaf_main_menu_item

      unless releaf_main_menu_item.start_with?('*')
        return url_for(:controller => _menu_item_controller_name(releaf_main_menu_item), :action => _menu_item_action_name(releaf_main_menu_item))
      else
        submenu_items = Releaf.base_menu[releaf_main_menu_item]

        # TODO find first item in submenu_items list, that current admin can access
        first_accessible_item = submenu_items[0][1][0] # currently will find first

        return url_for(:controller => _menu_item_controller_name(first_accessible_item), :action => _menu_item_action_name(first_accessible_item))
      end
    end

    def base_menu_items base_menu_name
      submenu_items = Releaf.base_menu[base_menu_name]
      return [] if submenu_items.blank?

      all_submenu_items = []
      submenu_items.each do |group|
        group[1].each { |item| all_submenu_items.push _menu_item_controller_name(item) }
      end

      return all_submenu_items
    end

    private

    def _menu_item_controller_name releaf_menu_item
      releaf_menu_item.split(/#/, 2).first
    end

    def _menu_item_action_name releaf_menu_item
      releaf_menu_item.split(/#/, 2)[2] || 'index'
    end

    def _check_if_this_is_valid_releaf_main_menu_item item
      raise ArgumentError, "not a string" unless item.is_a? String
      raise ArgumentError, "no such Releaf main menu item" unless Releaf.main_menu.include? item
    end


  end
end
