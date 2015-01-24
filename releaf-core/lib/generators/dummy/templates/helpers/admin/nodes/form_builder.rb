module Admin::Nodes
  class FormBuilder < Releaf::Content::Nodes::FormBuilder
    def node_fields
      super << :description
    end
  end
end
