module Releaf
  class RichtextAttachment < ActiveRecord::Base
    self.table_name = 'releaf_richtext_attachments'
    dragonfly_accessor :file
  end
end
