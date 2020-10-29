module Releaf::Permissions
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_presence_of :default_controller
    validates_uniqueness_of :name, case_sensitive: false

    has_many :users, dependent: :restrict_with_exception
    has_many :permissions, as: :owner, class_name: "Releaf::Permissions::Permission", dependent: :destroy
    accepts_nested_attributes_for :permissions, allow_destroy: true
  end
end
