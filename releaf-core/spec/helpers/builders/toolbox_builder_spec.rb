require "spec_helper"

describe Releaf::Builders::ToolboxBuilder, type: :class do
  class ToolboxBuilderTestHelper < ActionView::Base
    include FontAwesome::Rails::IconHelper
    include Releaf::ButtonHelper
    include Releaf::ApplicationHelper
  end

  subject { described_class.new(template) }
  let(:template){ ToolboxBuilderTestHelper.new }

  it "includes Releaf::Builders::Base" do
    expect(described_class.ancestors).to include(Releaf::Builders::Base)
  end

  it "includes Releaf::Builders::Template" do
    expect(described_class.ancestors).to include(Releaf::Builders::Template)
  end

  it "includes Releaf::Builders::ResourceToolbox" do
    expect(described_class.ancestors).to include(Releaf::Builders::ResourceToolbox)
  end

  describe "#items" do
    before{ allow(subject).to receive(:destroy_confirmation_link).and_return("x") }

    context "when no destroy feature is available" do
      it "returns array with destroy button html" do
        allow(subject).to receive(:feature_available?).with(:destroy).and_return(true)
        expect(subject.items).to eq(["x"])
      end
    end

    context "when destroy feature is not available" do
      it "returns empty array" do
        allow(subject).to receive(:feature_available?).with(:destroy).and_return(false)
        expect(subject.items).to eq([])
      end
    end
  end

  describe "#destroy_confirmation_link" do
    it "returns destroy confirmation link" do
      allow(subject).to receive(:destroy_confirmation_url).and_return("www.xxx")
      content = '<a class="button with-icon ajaxbox danger" title="Delete" href="www.xxx" data-modal="true"><i class="fa fa-trash-o fa-lg"></i>Delete</a>'
      expect(subject.destroy_confirmation_link).to eq(content)
    end
  end

  describe "#destroy_confirmation_url" do
    it "returns resource destroy confirmation url with index_url param" do
      subject.resource = Book.new(id: 99)
      allow(subject.template).to receive(:url_for).with(action: :confirm_destroy, id: 99, index_url: "y").and_return("x")
      allow(subject.template).to receive(:controller).and_return(Releaf::BaseController.new)
      allow(subject.controller).to receive(:index_url).and_return("y")
      expect(subject.destroy_confirmation_url).to eq("x")
    end
  end
end
