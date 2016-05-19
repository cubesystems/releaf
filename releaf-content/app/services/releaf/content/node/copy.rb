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
          new_node
        rescue ActiveRecord::RecordInvalid
          add_error_and_raise 'descendant invalid'
        else
          node.update_settings_timestamp
        end
      end

      def prevent_infinite_copy_loop
        return if node.self_and_descendants.find_by_id(parent_id).blank?
        add_error_and_raise("source or descendant node can't be parent of new node")
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
        return if node.content_id.blank?

        new_content = node.content.class.new(node.content.attributes.reject{ |k, v| content_dragonfly_attributes.push("id").include?(k) })
        duplicate_content_dragonfly_attributes(new_content)

        new_content.save!
        new_content
      end

      def duplicate_content_dragonfly_attributes(new_content)
        content_dragonfly_attributes.each do |attribute_name|
          accessor_name = attribute_name.gsub("_uid", "")
          dragonfly_attachment = node.content.send(accessor_name)

          if dragonfly_attachment.present?
            begin
              dragonfly_attachment.path  # verify that the file exists
            rescue Dragonfly::Job::Fetch::NotFound
              dragonfly_attachment = nil
            end
          end

          new_content.send("#{attribute_name}=", nil)
          new_content.send("#{accessor_name}=", dragonfly_attachment)
        end
      end

      def content_dragonfly_attributes
        node.content.class.attribute_names.select do |attribute_name|
          Releaf::Builders::Utilities::ResolveAttributeFieldMethodName.new(object: node.content, attribute_name: attribute_name).file?
        end
      end

      def make_copy
        new_node = duplicate_under

        node.children.each do |child|
          self.class.new(node: child, parent_id: new_node.id).make_copy
        end

        new_node
      end
    end
  end
end
