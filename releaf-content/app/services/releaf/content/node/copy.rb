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

        new_content = node.content.dup
        new_content.save!
        new_content
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
