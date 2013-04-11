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
      controllers = []

      menu = [
        {
          :controller => 'releaf/content',
          :helper => 'releaf_nodes'
        },
        {
          :permissions => [
            {:permissions =>   %w[releaf/admins releaf/roles]}
          ]
        },
        {
          :controller => 'releaf/translations',
          :helper => 'releaf_translation_groups'
        },
      ]

      menu.each do |menu_item|
        if menu_item.is_a? String
          controllers << menu_item
        elsif menu_item.is_a? Hash
          # hash ir submenu item
          if menu_item.keys.length == 1 and menu_item[menu_item.keys.first].is_a? Array
            menu_item[menu_item.keys.first].each do |submenu_section|
              # validate submenu section
              if submenu_section.keys.length == 1 and submenu_section[submenu_section.keys.first].is_a? Array
                submenu_section[submenu_section.keys.first].each do |submenu_item|
                  if submenu_item.is_a? String
                    controllers << submenu_item
                  end
                end
              end
            end
          elsif menu_item.has_key? :controller
            controllers << menu_item[:controller]
          end
        end

      end

      puts controllers


    end
  end

end
