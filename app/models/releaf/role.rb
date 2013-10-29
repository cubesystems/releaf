module Releaf
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_presence_of :default_controller
    validates_uniqueness_of :name, case_sensitive: false

    has_many :admins, dependent: :restrict_with_exception

    serialize :permissions

    alias_attribute :to_text, :name

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

      # always allow access to profile controller
      if controller_name == 'releaf/admin_profile'
        return true
      # always allow access to home controller, so we can route user to default controller
      elsif controller_name == 'releaf/home'
        return true
      end

      return permissions.try(:include?, controller_name)
    end

  end

end
