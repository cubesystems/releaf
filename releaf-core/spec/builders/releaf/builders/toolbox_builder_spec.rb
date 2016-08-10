require "rails_helper"

describe Releaf::Builders::ToolboxBuilder, type: :class do
  class ToolboxBuilderTestHelper < ActionView::Base
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

  it "includes Releaf::Builders::Resource" do
    expect(described_class.ancestors).to include(Releaf::Builders::Resource)
  end

  describe "#output" do
    it "returns safely joined items" do
      allow(subject).to receive(:items).and_return([ '<', ActiveSupport::SafeBuffer.new(">")])
      expect(subject.output).to eq("<li>&lt;</li><li>></li>")
    end
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
      allow(subject).to receive(:t).with("Delete").and_return("dlt")
      allow(subject).to receive(:destroy_confirmation_url).and_return("www.xxx")
      content = '<a class="button ajaxbox danger" title="dlt" href="www.xxx" data-modal="true">dlt</a>'
      expect(subject.destroy_confirmation_link).to eq(content)
    end
  end

  describe "#destroy_confirmation_url" do
    it "returns resource destroy confirmation url with index_path param" do
      subject.resource = Book.new(id: 99)
      allow(subject.template).to receive(:url_for).with(action: :confirm_destroy, id: 99, index_path: "y").and_return("x")
      allow(subject.template).to receive(:controller).and_return(Releaf::ActionController.new)
      allow(subject.controller).to receive(:index_path).and_return("y")
      expect(subject.destroy_confirmation_url).to eq("x")
    end
  end
end
