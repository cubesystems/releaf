require "rails_helper"

describe Releaf::Content::Nodes::ContentFormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
    def controller_scope_name; end
    def generate_url_releaf_content_nodes_path(args); end
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:node){ Node.new(content_type: "TextPage", slug: "b", id: 2,
                         parent: Node.new(content_type: "TextPage", slug: "a", id: 1)) }
  let(:object){ node.build_content }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#field_names" do
    it "returns array of node content object fields" do
      allow(object.class).to receive(:acts_as_node_fields).and_return(["a", "b"])
      expect(subject.field_names).to eq(["a", "b"])
    end
  end
end
