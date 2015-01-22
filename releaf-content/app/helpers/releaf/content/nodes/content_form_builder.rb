module Releaf::Content::Nodes
  class ContentFormBuilder < Releaf::Builders::FormBuilder
    def field_names
      object.class.releaf_fields_to_display(nil)
    end
  end
end
