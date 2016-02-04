require "rails_helper"

describe Releaf::Builders::View, type: :class do
  class ViewTestHelper < ActionView::Base
    include FontAwesome::Rails::IconHelper
  end

  class ViewTestIncluder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    include Releaf::Builders::View
  end

  subject { ViewTestIncluder.new(template) }
  let(:template){ ViewTestHelper.new }

  it "includes Releaf::Builders::Base" do
    expect(described_class.ancestors).to include(Releaf::Builders::Base)
  end

  it "includes Releaf::Builders::Template" do
    expect(described_class.ancestors).to include(Releaf::Builders::Template)
  end

  describe "#output" do
    before do
      allow(subject).to receive(:header).and_return(ActiveSupport::SafeBuffer.new("<"))
      allow(subject).to receive(:section).and_return(ActiveSupport::SafeBuffer.new(">"))
    end

    it "returns safely joined header and section outputs" do
      allow(subject).to receive(:dialog?).and_return(false)
      expect(subject.output).to eq("<>")
    end

    context "within dialog" do
      it "does not return header content" do
        allow(subject).to receive(:dialog?).and_return(true)
        expect(subject.output).to eq(">")
      end
    end
  end

  describe "#dialog?" do
    let(:controller){ Releaf::ActionController.new }

    before do
      allow(template).to receive(:controller).and_return(controller)
    end

    context "when controller has ajax mode enabled" do
      it "returns true" do
        allow(controller).to receive(:ajax?).and_return(true)
        expect(subject.dialog?).to be true
      end
    end

    context "when controller has ajax mode disabled" do
      it "returns false" do
        allow(controller).to receive(:ajax?).and_return(false)
        expect(subject.dialog?).to be false
      end
    end
  end

  describe "#dialog_name" do
    class UnitTestDialogBuilder
      include Releaf::Builders::Base
      include Releaf::Builders::Template
      include Releaf::Builders::View
    end

    it "returns normalized, dashed dialog name taken from dialog class name" do
      subject = UnitTestDialogBuilder.new(template)
      expect(subject.dialog_name).to eq("unit-test")

      subject = Releaf::Builders::EditBuilder.new(template)
      expect(subject.dialog_name).to eq("edit")
    end
  end

  describe "#header" do
    it "returns safely joined breadcrumbs, flash notices and header extras within header tag" do
      allow(subject).to receive(:breadcrumbs).and_return(ActiveSupport::SafeBuffer.new("breadcrumbs>"))
      allow(subject).to receive(:flash_notices).and_return(ActiveSupport::SafeBuffer.new(">_and_notices_"))
      allow(subject).to receive(:header_extras).and_return(ActiveSupport::SafeBuffer.new(">extras"))
      expect(subject.header).to eq("<header>breadcrumbs>>_and_notices_>extras</header>")
    end
  end

  describe "#section" do
    it "returns safely joined section blocks within section tag" do
      allow(subject).to receive(:section_attributes).and_return(class: "xx")
      allow(subject).to receive(:section_blocks).and_return([ '<', ActiveSupport::SafeBuffer.new(">")])
      expect(subject.section).to eq('<section class="xx">&lt;></section>')
    end
  end

  describe "#section_attributes" do
    context "within dialog" do
      it "returns hash with dialog classes" do
        allow(subject).to receive(:dialog?).and_return(true)
        allow(subject).to receive(:dialog_name).and_return("xxx")
        expect(subject.section_attributes).to eq(class: ["dialog", "xxx"])
      end
    end

    context "when not within dialog" do
      it "returns empty hash" do
        allow(subject).to receive(:dialog?).and_return(false)
        expect(subject.section_attributes).to eq({})
      end
    end
  end

  describe "#breadcrumbs" do
    context "when breadcrumbs template variable exists" do
      it "returns safely joined breadcrumbs items list within nav element" do
        allow(subject).to receive(:template_variable).with("breadcrumbs").and_return([:a, :b, :c])
        allow(subject).to receive(:breadcrumb_item).with(:a, false).and_return(">a")
        allow(subject).to receive(:breadcrumb_item).with(:b, false).and_return(ActiveSupport::SafeBuffer.new(">b"))
        allow(subject).to receive(:breadcrumb_item).with(:c, true).and_return(">c")
        content = '<nav><ul class="breadcrumbs">&gt;a>b&gt;c</ul></nav>'
        expect(subject.breadcrumbs).to eq(content)
      end
    end

    context "when breadcrumbs template variable does not exists" do
      it "returns nil" do
        allow(subject).to receive(:template_variable).with("breadcrumbs").and_return(nil)
        expect(subject.breadcrumbs).to be nil
      end
    end
  end

  describe "#breadcrumb_item" do
    context "when given breadcrumb item has url" do
      it "returns name wrapped within link" do
        expect(subject.breadcrumb_item({url: "asa", name: "x"}, true)).to eq('<li><a href="asa">x</a></li>')
      end
    end

    context "when given breadcrumb item has no url" do
      it "returns only name" do
        expect(subject.breadcrumb_item({name: "x"}, true)).to eq('<li>x</li>')
      end
    end

    it "adds breadcrumb icon after except when last element given" do
      expect(subject.breadcrumb_item({name: "x"}, true)).to eq('<li>x</li>')
      expect(subject.breadcrumb_item({name: "x"}, false)).to eq('<li>x<i class="fa fa-chevron-right"></i></li>')
    end
  end

  describe "#flash_notices" do
    it "returns safely joined flash items" do
      allow(subject).to receive(:flash).and_return(a: "xx", b: "yy")
      allow(subject).to receive(:flash_item).with(:a, "xx").and_return(ActiveSupport::SafeBuffer.new("<a"))
      allow(subject).to receive(:flash_item).with(:b, "yy").and_return("b>")
      expect(subject.flash_notices).to eq("<ab&gt;")
    end
  end

  describe "#flash_item" do
    it "returns flash item" do
      expect(subject.flash_item(:error, "some error")).to eq('<div class="flash" data-type="error">some error</div>')
    end

    it "supports flash item data as hash" do
      expect(subject.flash_item(:error, "id" => "unique", "message" => "errrrrror")).to eq('<div class="flash" data-type="error" data-id="unique">errrrrror</div>')
    end
  end

  describe "#header_extras" do
    it "returns nil (method to override in later classes)" do
      expect(subject.header_extras).to be nil
    end
  end

  describe "#section_blocks" do
    it "returns array of section header, body and footer blocks" do
      allow(subject).to receive(:section_header).and_return("a")
      allow(subject).to receive(:section_body).and_return("b")
      allow(subject).to receive(:section_footer).and_return("c")

      expect(subject.section_blocks).to eq(["a", "b", "c"])
    end
  end

  describe "#section_header" do
    it "returns header content with header extras" do
      allow(subject).to receive(:section_header_text).and_return("sektion h")
      allow(subject).to receive(:section_header_extras).and_return("extras")
      expect(subject.section_header).to eq("<header><h1>sektion h</h1>extras</header>")
    end
  end

  describe "#section_header_text" do
    it "returns nil (method to override in later classes)" do
      expect(subject.section_header_text).to be nil
    end
  end

  describe "#section_header_extras" do
    it "returns nil (method to override in later classes)" do
      expect(subject.section_header_extras).to be nil
    end
  end

  describe "#section_body" do
    it "returns nil (method to override in later classes)" do
      expect(subject.section_body).to be nil
    end
  end

  describe "#section_footer" do
    it "returns footer with footer attributes and content" do
      allow(subject).to receive(:section_footer_class).and_return(["axx", "b"])
      allow(subject).to receive(:footer_tools).and_return("footer content")
      expect(subject.section_footer).to eq('<footer class="axx b">footer content</footer>')
    end
  end

  describe "#section_footer_class" do
    context "within dialog" do
      it "returns nil" do
        allow(subject).to receive(:dialog?).and_return(true)
        expect(subject.section_footer_class).to be nil
      end
    end

    context "when not within dialog" do
      it "returns :main" do
        allow(subject).to receive(:dialog?).and_return(false)
        expect(subject.section_footer_class).to eq(:main)
      end
    end
  end

  describe "#footer_tools" do
    it "returns footer tools" do
      allow(subject).to receive(:footer_blocks).and_return([ActiveSupport::SafeBuffer.new("<a"), "b>"])
      expect(subject.footer_tools).to eq('<div class="tools"><ab&gt;</div>')
    end
  end

  describe "#footer_blocks" do
    it "returns array of footer primary and secondary blocks" do
      allow(subject).to receive(:footer_primary_block).and_return("a")
      allow(subject).to receive(:footer_secondary_block).and_return("b")

      expect(subject.footer_blocks).to eq(["a", "b"])
    end
  end

  describe "#footer_primary_block" do
    it "returns footer tools" do
      allow(subject).to receive(:footer_primary_tools).and_return([ActiveSupport::SafeBuffer.new("<a"), "b>"])
      expect(subject.footer_primary_block).to eq('<div class="primary"><ab&gt;</div>')
    end
  end

  describe "#footer_secondary_block" do
    it "returns footer tools" do
      allow(subject).to receive(:footer_secondary_tools).and_return([ActiveSupport::SafeBuffer.new("<a"), "b>"])
      expect(subject.footer_secondary_block).to eq('<div class="secondary"><ab&gt;</div>')
    end
  end

  describe "#footer_primary_tools" do
    it "returns nil (method to override in later classes)" do
      expect(subject.footer_primary_tools).to be nil
    end
  end

  describe "#footer_secondary_tools" do
    it "returns nil (method to override in later classes)" do
      expect(subject.footer_secondary_tools).to be nil
    end
  end
end
