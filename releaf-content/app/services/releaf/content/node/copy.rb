module Releaf
  module Content::Node
    class Copy
      include Releaf::Content::Node::Service
      attribute :parent_id, Integer, strict: false

      def call
        prevent_infinite_copy_loop
        begin
          new_node = nil
          node.class.transaction do
            new_node = make_copy
          end
        rescue ActiveRecord::RecordInvalid
          add_error_and_raise 'descendant invalid'
        else
          node.update_settings_timestamp
          new_node
        end
      end

      def prevent_infinite_copy_loop
        return if node.self_and_descendants.find_by_id(parent_id).blank?
        add_error_and_raise("source or descendant node can't be parent of new node")
      end

      def make_copy
        new_node = duplicate_under

        node.children.each do |child|
          self.class.new(node: child, parent_id: new_node.id).make_copy
        end

        new_node
      end

      def duplicate_under
        new_node = nil
        node.class.transaction do
          new_node = node.class.new
          new_node.assign_attributes_from(node)
          new_node.content_id = duplicate_content.try(:id)
          new_node.prevent_auto_update_settings_timestamp do
            Releaf::Content::Node::SaveUnderParent.call(node: new_node, parent_id: parent_id)
          end
        end

        new_node
      end

      def duplicate_content
        if node.content.present?
          new_content = duplicate_object(node.content)
          new_content.save!
          new_content
        else
          nil
        end
      end

      def duplicate_object object
        object.deep_clone include: duplicatable_associations(object.class) do |original, copy|
          supplement_object_duplication(original, copy)
        end
      end

      def supplement_object_duplication(original, copy)
        duplicate_dragonfly_attachments(original, copy)
      end

      def duplicatable_associations(owner_class)
        Releaf::ResourceBase.new(owner_class).associations.collect do |association|
          { association.name => duplicatable_associations(association.klass) }
        end
      end

      def duplicate_dragonfly_attachments(original, copy)
        attachment_keys = original.dragonfly_attachments.keys
        return unless attachment_keys.present?

        # during the dup() call the copy object has its dragonfly_attachments property duplicated from the original.
        # here it gets set to nil to force its reinitialization on next access
        copy.instance_variable_set(:@dragonfly_attachments, nil)

        # all uids must be cleared in a separate loop before accessing any of the attachments
        # (accessing any of the accessors regenerates the dragonfly_attachments collection and loads all uids)
        attachment_keys.each { |accessor| copy.send("#{accessor}_uid=", nil) }

        # once all uids have been reset, each attachment may be reassigned from the original.
        # reassignment forces dragonfly to internally treat the new attachment as a copy
        attachment_keys.each do |accessor|
          attachment = original.send(accessor)

          if attachment.present?
            begin
              attachment.path  # verify that the file exists
            rescue Dragonfly::Job::Fetch::NotFound
              attachment = nil
            end
          end

          copy.send("#{accessor}=", attachment)
        end
      end
    end
  end
end
