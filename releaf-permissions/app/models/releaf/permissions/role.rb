module Releaf::Permissions
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_presence_of :default_controller
    validates_uniqueness_of :name, case_sensitive: false

    has_many :users, dependent: :restrict_with_exception

    serialize :permissions, Array
    before_validation{|model| model.permissions.reject!(&:blank?) if model.permissions}

    alias_attribute :to_text, :name
  end
end
