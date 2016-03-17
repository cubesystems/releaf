module Releaf
  module Content::Node
    module Service
      extend ActiveSupport::Concern
      include Releaf::Service

      included do
        attribute :node, Releaf::Content::Node
      end

      def add_error_and_raise(error)
        node.errors.add(:base, error)
        raise ActiveRecord::RecordInvalid.new(node)
      end
    end
  end
end
