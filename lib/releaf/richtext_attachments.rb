module Releaf
  module RichtextAttachments

    protected

    def manage_attachments
      collected_uuids = richtext_attachment_collected_uuids
      if collected_uuids.present?
        self.attachments.where('uuid NOT IN (?)', collected_uuids).delete_all
        Attachment.where(:uuid => collected_uuids, :richtext_attachment_type => nil, :richtext_attachment_id => nil).
          update_all ["richtext_attachment_type = :class, richtext_attachment_id = :id", {:class => self.class.name, :id => self.id} ]
      else
        self.attachments.delete_all
      end
    end

    def richtext_attachment_collected_uuids
      collected_uuids = []

      richtext_columns.each do |column|
        wrapped_text = "<root>#{self.send(column)}</root>"
        doc = Nokogiri::XML(wrapped_text)
        doc.css('[data-attachment-id]').each do |node|
          collected_uuids.push node['data-attachment-id']
        end
      end

      return collected_uuids.uniq
    end

    def richtext_columns
      columns = self.class.column_names
      columns += self.class.translated_attribute_names.map(&:to_s) if self.class.translates?
      columns.grep(/_html$/)
    end

    public

    def self.included base
      base.class_eval do
        has_many :attachments, :as => :richtext_attachment, :dependent => :destroy, :class_name => 'Releaf::Attachment'
        accepts_nested_attributes_for :attachments, :allow_destroy => true
        after_save :manage_attachments
      end
    end
  end
end
