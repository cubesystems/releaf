module Releaf
  module RichtextAttachments
    def self.included base
      base.class_eval do
        has_many :attachments, :as => :richtext_attachment, :dependent => :destroy, :class_name => 'Releaf::Attachment'
        accepts_nested_attributes_for :attachments, :allow_destroy => true
        attr_accessible :attachments_attributes
      end
    end
  end
end
