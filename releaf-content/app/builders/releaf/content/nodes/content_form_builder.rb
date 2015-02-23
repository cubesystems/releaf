module Releaf::Content::Nodes
  class ContentFormBuilder < Releaf::Builders::FormBuilder
    def field_names
      object.class.acts_as_node_fields
    end
  end
end
