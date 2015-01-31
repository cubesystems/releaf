module Releaf
  class RichtextAttachment < ActiveRecord::Base
    self.table_name = 'releaf_richtext_attachments'
    self.primary_key = 'uuid'

    before_create :assign_uuid
    belongs_to :owner, polymorphic: true
    dragonfly_accessor :file

    def assign_uuid
      self.uuid = SecureRandom.uuid
    end
  end
end
