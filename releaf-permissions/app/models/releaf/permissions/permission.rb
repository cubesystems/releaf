module Releaf::Permissions
  class Permission < ActiveRecord::Base
    self.table_name = 'releaf_permissions'
    belongs_to :owner, polymorphic: true, autosave: false
  end
end
