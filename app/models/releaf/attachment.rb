module Releaf
  class Attachment < ActiveRecord::Base
    self.table_name = 'releaf_attachments'

    belongs_to :richtext_attachment, :polymorphic => true

    file_accessor :file
    attr_accessible \
      :file,
      :retained_file

    def type
      return 'image' if file_type =~ %r#^image/#
    end

  end
end
