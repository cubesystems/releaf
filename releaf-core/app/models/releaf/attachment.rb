module Releaf
  class Attachment < ActiveRecord::Base
    self.table_name = 'releaf_attachments'
    require 'uuidtools'

    self.primary_key = 'uuid'
    before_create :generate_uuid
    belongs_to :richtext_attachment, :polymorphic => true
    dragonfly_accessor :file

    def type
      return 'image' if file_type =~ %r#^image/#
    end

    private

    def generate_uuid
      self[:uuid] = UUIDTools::UUID.random_create.to_s if self.uuid.blank?
    end

  end
end
