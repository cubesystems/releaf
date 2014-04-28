module Releaf
  module ContentNode
    # Validator to test if node is valid, when created under given parrent node
    #
    # validator needs :for and :under options, both can be either array of classes
    # or single class.
    #
    # :for option specifies for which nodes validation should be applied
    #
    # :under option specifies under which nodes given node can be added
    #
    # @example
    #
    #   class Node < ActiveRecord::Base
    #     includes Releaf::ContentNode
    #     validates_with Releaf::ContentNode::ParentValidator, for: [Text, Book], under: Store
    #   end
    #
    class ParentValidator < ActiveModel::Validator

      def validate node
        @node = node
        return if node_parent_valid?
        node.errors.add(:content_type, 'invalid parent node')
      end

      private

      def node_parent_valid?
        return true unless child_class_names.include? @node.content_type
        return parent_class_names.include? @node.parent.try(:content_type)
      end

      def child_class_names
        target_class_names :for
      end

      def parent_class_names
        target_class_names :under
      end

      def target_class_names target_type
        [options.fetch(target_type, [])].flatten.map(&:name)
      end

    end
  end
end
