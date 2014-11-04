require "spec_helper"

describe Releaf::Content::NodeFormBuilder, type: :class, pending: true do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Node.new }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#render_locale" do
    it "renders customized field" do
    end
  end

  describe "#render_content_type" do
    it "renders customized field" do
    end
  end

  describe "#render_slug" do
    it "renders customized field" do
    end
  end

  describe "#render_item_position" do
    it "renders customized field" do
    end
  end
end
