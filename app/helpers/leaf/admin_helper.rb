module Leaf
  module AdminHelper

    def has_many_association_names obj
      reflect_all_asoc = obj.reflect_on_all_associations(:has_many)
      has_many_asoc_names = reflect_all_asoc.map { |asoc| asoc.name }

      reflect_all_asoc.each do |asoc|
        next unless asoc.options.has_key?(:through)
        has_many_asoc_names.delete(asoc.name)
      end

      # don't show translations associaton which is created by globalize3
      has_many_asoc_names - [:translations]
    end


    def is_this_main_menu_item_active? leaf_main_menu_item
      _check_if_this_is_valid_leaf_main_menu_item leaf_main_menu_item

      unless leaf_main_menu_item.start_with?('*')
        return params[:controller] == _menu_item_controller_name(leaf_main_menu_item)
      else
        return base_menu_items(leaf_main_menu_item).include? params[:controller]
      end
    end

    def main_menu_item_url leaf_main_menu_item, options={}
      # TODO implement options
      _check_if_this_is_valid_leaf_main_menu_item leaf_main_menu_item

      unless leaf_main_menu_item.start_with?('*')
        return url_for(:controller => _menu_item_controller_name(leaf_main_menu_item), :action => _menu_item_action_name(leaf_main_menu_item))
      else
        submenu_items = Leaf.base_menu[leaf_main_menu_item]

        # TODO find first item in submenu_items list, that current admin can access
        first_accessible_item = submenu_items[0][1][0] # currently will find first

        return url_for(:controller => _menu_item_controller_name(first_accessible_item), :action => _menu_item_action_name(first_accessible_item))
      end
    end

    def base_menu_items base_menu_name
      submenu_items = Leaf.base_menu[base_menu_name]
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
