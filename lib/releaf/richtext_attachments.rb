module Releaf
  module RichtextAttachments

    protected

    def manage_attachments
      columns = self.class.column_names
      columns += self.class.translates.map(&:to_s) if self.class.respond_to? :translations_table_name

      richtext_columns = columns.grep(/_html$/)

      richtext_columns.each do |column|
        wrapped_text = "<root>#{self.send(column)}</root>"
        doc = Nokogiri::XML(wrapped_text)
        collected_ids = []
        doc.css('a[data-attachment-id], img[data-attachment-id]').each do |node|
          collected_ids.push node['data-attachment-id']
        end

        self.attachments.where('id NOT IN (?)', collected_ids).delete_all
        Attachment.where(:id => collected_ids).update_all ["richtext_attachment_type = :class, richtext_attachment_id = :id", {:class => self.class.name, :id => self.id} ]
      end

    end

    public

    def self.included base
      base.class_eval do
        has_many :attachments, :as => :richtext_attachment, :dependent => :destroy, :class_name => 'Releaf::Attachment'
        accepts_nested_attributes_for :attachments, :allow_destroy => true
        attr_accessible :attachments_attributes
        after_save :manage_attachments
      end
    end
  end
end
