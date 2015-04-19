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

    # Load all permissions and check given controller against roles permissions.
    # In this way permissions are cached resulting only single db hit per multiple permissions checks.
    #
    # @param controller_name [String] controller name to check permissions against (ex. products)
    # @return [true, false] whether controller is permitted for role
    def controller_permitted?(controller_name)
      permissions.find{|item| item.permission == "controller.#{controller_name}"}.present?
    end
  end
end
