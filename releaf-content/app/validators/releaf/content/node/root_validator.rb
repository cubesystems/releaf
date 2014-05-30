module Releaf
  module Content::Node
    # Validator to test if node is valid root node
    #
    # Validator needs :allow option.
    #
    # :allow option specifies which nodes are valid root nodes.
    #
    # @example
    #
    #   class Node < ActiveRecord::Base
    #     includes Releaf::Content::Node
    #     validates_with Releaf::Content::Node::RootValidator, allow: [Text, Store]
    #   end
    #
    # In example above only Text and Book nodes can be created as root nodes
    class RootValidator < ActiveModel::Validator

      def validate node
        @node = node

        if allowed_root_node?
          node.errors.add(:content_type, "can't be subnode") if @node.parent.present?
        else
          node.errors.add(:content_type, "can't be root node") if @node.parent.nil?
        end

        remove_instance_variable(:@node)
      end

      private

      def allowed_root_node?
        root_class_names.include? @node.content_type
      end

      def root_class_names
        [options.fetch(:allow, [])].flatten.map(&:name)
      end

    end
  end
end
