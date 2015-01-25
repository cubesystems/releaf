module ActionController
  module Acts #:nodoc:
    # This +acts_as+ extension provides the capabilities for attaching object to nodes tree.
    #
    # Text example:
    #
    #   class ContactFormController < ActionController::Base
    #     has_many :acts_as_node
    #   end
    #
    module Node #:nodoc:
      def self.included(base)
        base.extend(::ActsAsNode::ClassMethods)
      end
    end
  end
end
