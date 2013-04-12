module Releaf
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false

    has_many :admins

    serialize :permissions

    attr_accessible \
      :name,
      :default_controller,
      :permissions

    alias_attribute :to_text, :name

    scope :order_by, lambda { |field=:name| order(field) }

    # Allow destroying of role if no Releaf::Admin object is using it
    def destroy
      if Releaf::Admin.where(:role_id => id).count == 0
        super
      end
    end

    # Return true/false access for given controller and action
    # @param [Controller, String or class that inherit ActionController::Base] controller to check access
    # @param [Action, String] action to check access
    # @return [Boolean] access to controller and action
    def authorize!(controller, action = nil)

      if controller.is_a? String
        controller_name = controller
      elsif controller.class < ActionController::Base
        controller_name = controller.class.to_s
      else
        raise ArgumentError, 'Argument is neither String or class that inherit ActionController::Base'
      end

      # clean controller in name if left
      controller_name = controller_name.gsub("Controller", "")

      # final convertation to underscore
      controller_name = controller_name.underscore

      # tinymce is checked against content controller access
      if controller_name ==  "releaf/tinymce_assets"
        controller_name = "releaf/content"
      end

      return permissions.include? (controller_name)
    end

    def self.test
      controllers = {}

      menu = [
        'releaf/admins',
        {
          :controller => 'releaf/content',
          :helper => 'releaf_nodes'
        },
        {
          :name => "permissions",
          :sections => [
            {
              :name => "permissions",
              :items =>   %w[releaf/admins releaf/roles]
            }
            #{:permissions =>   %w[releaf/admins releaf/roles]}
          ]
        },
        {
          :controller => 'releaf/translations',
          :helper => 'releaf_translation_groups'
        },
      ]

      menu.each_with_index do |menu_item, index|
        if menu_item.is_a? String
          menu[index] = {:controller => menu_item}
          controllers[menu_item] = menu[index]
        elsif menu_item.is_a? Hash
          # submenu hash
          if menu_item.has_key? :sections
            menu_item[:sections].each_with_index do |submenu_section, submenu_index|
              if submenu_section.has_key? :name and submenu_section.has_key? :items
                submenu_section[:items].each_with_index do |submenu_item, submenu_item_index|
                  if submenu_item.is_a? String
                    submenu_section[:items][submenu_item_index] = {:controller => submenu_item}
                    controllers[submenu_item] = {:controller => submenu_item}
                  elsif submenu_item.has_key? :controller
                    controllers[submenu_item[:controller]] = submenu_item
                  end
                end
              end
            end
          elsif menu_item.has_key? :controller
            controllers[menu_item[:controller]] = menu_item
          end
        end
      end

      puts menu
      puts "xxxxxxxxxxxx"
      return controllers
    end
  end

end
