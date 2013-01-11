module Leaf
  module AdminHelper

    def is_this_main_menu_item_active? leaf_main_menu_item
      _check_if_this_is_valid_leaf_main_menu_item leaf_main_menu_item

      unless leaf_main_menu_item.start_with?('*')
        return params[:controller] == _menu_item_controller_name(leaf_main_menu_item)
      else
        return alt_menu_items(leaf_main_menu_item).include? params[:controller]
      end
    end

    def main_menu_item_url leaf_main_menu_item, options={}
      # TODO implement options
      _check_if_this_is_valid_leaf_main_menu_item leaf_main_menu_item

      unless leaf_main_menu_item.start_with?('*')
        return url_for(:controller => _menu_item_controller_name(leaf_main_menu_item), :action => _menu_item_action_name(leaf_main_menu_item))
      else
        submenu_items = Leaf.alt_menu[leaf_main_menu_item]

        # TODO find first item in submenu_items list, that current admin can access
        first_accessible_item = submenu_items[0][1][0] # currently will find first

        return url_for(:controller => _menu_item_controller_name(first_accessible_item), :action => _menu_item_action_name(first_accessible_item))
      end
    end

    def alt_menu_items alt_menu_name
      submenu_items = Leaf.alt_menu[alt_menu_name]
      return [] if submenu_items.blank?

      all_submenu_items = []
      submenu_items.each do |group|
        group[1].each { |item| all_submenu_items.push _menu_item_controller_name(item) }
      end

      return all_submenu_items
    end

    private

    def _menu_item_controller_name leaf_menu_item
      leaf_menu_item.split(/#/, 2).first
    end

    def _menu_item_action_name leaf_menu_item
      leaf_menu_item.split(/#/, 2)[2] || 'index'
    end

    def _check_if_this_is_valid_leaf_main_menu_item item
      raise ArgumentError, "not a string" unless item.is_a? String
      raise ArgumentError, "no such Leaf main menu item" unless Leaf.main_menu.include? item
    end


  end
end
