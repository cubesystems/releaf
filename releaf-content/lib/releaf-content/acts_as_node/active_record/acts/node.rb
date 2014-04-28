module ActiveRecord
  module Acts #:nodoc:
    module Node #:nodoc:
      def self.included(base)
        base.extend(::ActsAsNode::ClassMethods)
        base.extend(ClassMethods)
      end

      # This +acts_as+ extension provides the capabilities for attaching object to nodes tree.
      #
      # Text example:
      #
      #   class Text < ActiveRecord::Base
      #     has_many :acts_as_node
      #   end
      #
      module ClassMethods
        def acts_as_node(options = {})
          options[:permit_attributes].unshift :id if options.has_key? :permit_attributes
          super options
          include ::ActiveRecord::Acts::Node::InstanceMethods
        end

        # Returns fields to display for releaf content controller
        #
        # @param [String] action for which fields will be displayed
        #
        # @return [Array] list of fields to display
        def releaf_fields_to_display action
          column_names - %w[id created_at updated_at]
        end
      end

      # All the methods available to a record that has had <tt>acts_as_node</tt> specified.
      module InstanceMethods

        # Return object corresponding node object
        # @return [::Node]
        def node
          # TODO class name should be configurable
          ::Node.find_by(content_type: self.class.name, content_id: id)
        end

      end
    end
  end
end
