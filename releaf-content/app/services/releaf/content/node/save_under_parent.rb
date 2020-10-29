module Releaf
  module Content::Node
    class SaveUnderParent
      include Releaf::Content::Node::Service
      attribute :parent_id, Integer, strict: false

      def call
        node.parent_id = parent_id
        if node.validate_root_locale_uniqueness?
          # When copying root nodes it is important to reset locale to nil.
          # Later user should fill in locale. This is needed to prevent
          # Rails errors about conflicting routes.
          node.locale = nil
        end

        node.maintain_name
        node.maintain_slug
        node.save!
      end
    end
  end
end
