require "rails_helper"

describe Releaf::Permissions::Page::LayoutBuilder, type: :class do
  class PermissionsLayoutBuilderView < ActionView::Base; end

  let(:controller){ Releaf::RootController.new }
  let(:template){ PermissionsLayoutBuilderView.new }
  subject { described_class.new(template) }

  before do
    allow(subject).to receive(:controller).and_return(controller)
  end

  it "inherits Releaf::Builders::Page::LayoutBuilder" do
    expect(described_class.superclass).to eq(Releaf::Builders::Page::LayoutBuilder)
  end

  describe "#header_builder" do
    it "returns `Releaf::Permissions::Page::HeaderBuilder` class" do
      expect(subject.header_builder).to eq(Releaf::Permissions::Page::HeaderBuilder)
    end
  end

  describe "#menu_builder" do
    it "returns `Releaf::Permissions::Page::MenuBuilder` class" do
      expect(subject.menu_builder).to eq(Releaf::Permissions::Page::MenuBuilder)
    end
  end

  describe "#body_content_blocks" do
    before do
      allow(subject).to receive(:header).and_return("_header")
      allow(subject).to receive(:menu).and_return("_menu")
      allow(subject).to receive(:notifications).and_return("_notifications")
      allow(subject).to receive(:assets).and_return("_assets_")
    end

    context "when controller responds to `authorized?` and `authorized?` call return true" do
      it "returns `super` content" do
        allow(controller).to receive(:authorized?).and_return(true)
        expect(subject.body_content_blocks{ "x" }).to eq(["_header", "_menu", "<main id=\"main\">x</main>",
                                                          "_notifications", "_assets_"])
      end
    end

    context "when controller responds to `authorized?` and `authorized?` call return false" do
      it "returns given block content" do
        allow(controller).to receive(:authorized?).and_return(false)
        expect(subject.body_content_blocks{ "x" }).to eq(["x"])
      end
    end

    context "when controller does not responds to `authorized?`" do
      it "returns given block content" do
        allow(controller).to receive(:respond_to?).with(:authorized?).and_return(false)
        expect(subject.body_content_blocks{ "x" }).to eq(["x"])
      end
    end
  end
end
