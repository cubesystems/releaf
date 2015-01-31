module Releaf::RichtextAttachments
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      has_many :releaf_richtext_attachments, dependent: :destroy, class_name: Releaf::RichtextAttachment, as: :owner
      accepts_nested_attributes_for :releaf_richtext_attachments, allow_destroy: true
      after_save :maintain_releaf_richtext_attachments
    end

    def maintain_releaf_richtext_attachments
      uuids = releaf_richtext_attachment_uuids
      delete_conditions = nil
      if uuids.present?
        delete_conditions = ['uuid NOT IN (?)', uuids]
        register_new_releaf_richtext_attachments(uuids)
      end
      releaf_richtext_attachments.where(delete_conditions).destroy_all
    end

    def register_new_releaf_richtext_attachments(uuids)
      Releaf::RichtextAttachment
        .where(uuid: uuids, owner_type: nil, owner_id: nil)
        .update_all(owner_type: self.class.name, owner_id: id)
    end

    def releaf_richtext_attachment_uuids
      uuids = []

      richtext_columns.each do |column|
        wrapped_text = "<root>#{self.send(column)}</root>"
        doc = Nokogiri::XML(wrapped_text)
        doc.css('[data-attachment-id]').each do |node|
          uuids << node['data-attachment-id']
        end
      end

      uuids.uniq
    end

    def richtext_columns
      columns = self.class.column_names
      columns += self.class.translated_attribute_names.map(&:to_s) if self.class.translates?
      columns.grep(/_html$/)
    end
  end
end
