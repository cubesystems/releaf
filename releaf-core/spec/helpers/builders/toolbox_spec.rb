require "spec_helper"

describe Releaf::Builders::Toolbox, type: :class do
  class ToolboxTestHelper < ActionView::Base
  end

  class ToolboxTestIncluder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    include Releaf::Builders::Toolbox
  end

  subject { ToolboxTestIncluder.new(template) }
  let(:template){ ToolboxTestHelper.new }

  describe "#output" do
    it "returns safely joined items" do
      allow(subject).to receive(:items).and_return([ '<', ActiveSupport::SafeBuffer.new(">")])
      expect(subject.output).to eq("&lt;>")
    end
  end

  describe "#items" do
    it "returns empty array" do
      expect(subject.items).to eq([])
    end
  end
end
