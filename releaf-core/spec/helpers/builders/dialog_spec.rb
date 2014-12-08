require "spec_helper"

describe Releaf::Builders::Dialog, type: :class do
  class DialogTestHelper < ActionView::Base
  end

  class UnitTestDialogBuilder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    include Releaf::Builders::Dialog
    def section_blocks
      ['<', ActiveSupport::SafeBuffer.new(">")]
    end
  end

  subject { UnitTestDialogBuilder.new(template) }
  let(:template){ DialogTestHelper.new }

  describe "#output" do
    it "returns safely joined items within section tag with applied classes" do
      content = '<section class="dialog unit-test">&lt;></section>'
      expect(subject.output).to eq(content)
    end
  end

  describe "#classes" do
    it "returns empty array" do
      allow(subject).to receive(:dialog_name).and_return("randomname")
      expect(subject.classes).to eq(["dialog", "randomname"])
    end
  end

  describe "#dialog_name" do
    it "returns normalized, dashed dialog name taken from dialog class name" do
      expect(subject.dialog_name).to eq("unit-test")
    end
  end
end
