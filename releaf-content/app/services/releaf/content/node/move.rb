module Releaf
  module Content::Node
    class Move
      include Releaf::Content::Node::Service
      attribute :parent_id, Integer, strict: false

      def call
        return node if node.parent_id.to_i == parent_id

        node.class.transaction do
          Releaf::Content::Node::SaveUnderParent.call(node: node, parent_id: parent_id)

          node.descendants.each do |descendant_node|
            next if descendant_node.valid?
            add_error_and_raise("descendant invalid")
          end
        end

        node
      end
    end
  end
end
