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
        def acts_as_node(params: nil, fields: nil)
          super
          include ::ActiveRecord::Acts::Node::InstanceMethods
        end

        def acts_as_node_params
          if acts_as_node_configuration[:params].nil?
            Releaf::ResourceParams.new(self).values << :id
          else
            acts_as_node_configuration[:params] << :id
          end
        end

        # Returns fields to display for releaf content controller
        #
        # @return [Array] list of fields to display
        def acts_as_node_fields
          if acts_as_node_configuration[:fields].nil?
            Releaf::ResourceFields.new(self).values
          else
            acts_as_node_configuration[:fields]
          end
        end
      end

      # All the methods available to a record that has had <tt>acts_as_node</tt> specified.
      module InstanceMethods

      end
    end
  end
end
