module Releaf
  class Attachment < ActiveRecord::Base
    self.table_name = 'releaf_attachments'

    belongs_to :richtext_attachment, :polymorphic => true

    file_accessor :file
    attr_accessible \
      :file,
      :retained_file

  end
end
