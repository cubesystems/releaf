require "spec_helper"

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
    it "returns safely joined header and section outputs" do
      allow(subject).to receive(:header).and_return(ActiveSupport::SafeBuffer.new("<"))
      allow(subject).to receive(:section).and_return(ActiveSupport::SafeBuffer.new(">"))
      expect(subject.output).to eq("<>")
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
      allow(subject).to receive(:section_blocks).and_return([ '<', ActiveSupport::SafeBuffer.new(">")])
      expect(subject.section).to eq("<section>&lt;></section>")
    end
  end

  describe "#breadcrumbs" do
    context "when breadcrumbs template variable exists" do
      it "returns safely joined breadcrumbs items list within nav element" do
        allow(subject).to receive(:template_variable).with("breadcrumbs").and_return([:a, :b, :c])
        allow(subject).to receive(:breadcrumb_item).with(:a, false).and_return(">a")
        allow(subject).to receive(:breadcrumb_item).with(:b, false).and_return(ActiveSupport::SafeBuffer.new(">b"))
        allow(subject).to receive(:breadcrumb_item).with(:c, true).and_return(">c")
        content = '<nav><ul class="block breadcrumbs">&gt;a>b&gt;c</ul></nav>'
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
      expect(subject.breadcrumb_item({name: "x"}, false)).to eq('<li>x<i class="fa fa-small fa-chevron-right"></i></li>')
    end
  end

  describe "#flash_notices", pending: true do
  end

  describe "#flash_item", pending: true do
  end

  describe "#header_extras" do
    it "returns nil (method to override in later classes)" do
      expect(subject.header_extras).to be nil
    end
  end

  describe "#section_blocks", pending: true do
  end

  describe "#section_header", pending: true do
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

  describe "#section_footer", pending: true do
  end

  describe "#section_footer_class" do
    it "returns :main" do
      expect(subject.section_footer_class).to eq(:main)
    end
  end

  describe "#footer_tools", pending: true do
  end

  describe "#footer_blocks", pending: true do
  end

  describe "#footer_primary_block", pending: true do
  end

  describe "#footer_secondary_block", pending: true do
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
