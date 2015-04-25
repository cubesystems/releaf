module Releaf::Permissions
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_presence_of :default_controller
    validates_uniqueness_of :name, case_sensitive: false

    has_many :users, dependent: :restrict_with_exception
    has_many :permissions, as: :owner, class_name: "Releaf::Permissions::Permission", dependent: :destroy
    accepts_nested_attributes_for :permissions, allow_destroy: true

    alias_attribute :to_text, :name

    # Check whether given controller name is within roles allowed controller list
    #
    # @param controller_name [String] controller name to check permissions against (ex. products)
    # @return [true, false] whether controller is permitted for role
    def controller_permitted?(controller_name)
      allowed_controllers.include?(controller_name)
    end

    # Load all permissions and build list with allowed controler.
    # In this way permissions are cached resulting only single db hit per multiple permissions checks.
    #
    # @return [Array] array of allowed controller names
    def allowed_controllers
      permissions.map{|permission| self.class.controller_name_from_permission(permission) }.compact
    end

    private

    def self.controller_name_from_permission(permission)
      match = permission.permission.match(/^controller\.(.+)/)
      match[1] if match
    end
  end
end
