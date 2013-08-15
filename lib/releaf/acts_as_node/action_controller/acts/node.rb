module ActionController
  module Acts #:nodoc:
    module Node #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      # This +acts_as+ extension provides the capabilities for attaching object to nodes tree.
      #
      # Text example:
      #
      #   class ContactFormController < ActionController::Base
      #     has_many :acts_as_node
      #   end
      #
      module ClassMethods
        # There are no configuration options yet.
        #
        def acts_as_node(options = {})
          configuration = {}
          configuration.update(options) if options.is_a?(Hash)

          ActsAsNode.register_class(self.name)

          class_eval <<-EOV
            include ::ActionController::Acts::Node::InstanceMethods

            # Load all nodes for class
            def self.nodes
              Releaf::Node.where(content_type: self.name)
            end
         EOV
        end
      end

      # All the methods available to a record that has had <tt>acts_as_node</tt> specified.
      module InstanceMethods

        # Return list of editable fields
        def node_editable_fields
          []
        end
      end
    end
  end
end
