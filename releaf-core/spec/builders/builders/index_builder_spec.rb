require "spec_helper"

describe Releaf::Builders::IndexBuilder, type: :class do
  class IndexBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  let(:template){ IndexBuilderTestHelper.new }
  let(:subject){ described_class.new(template) }

  it "includes Releaf::Builders::View" do
    expect(described_class.ancestors).to include(Releaf::Builders::View)
  end

  it "includes Releaf::Builders::Collection" do
    expect(described_class.ancestors).to include(Releaf::Builders::Collection)
  end

  describe "#dialog?" do
    it "returns false" do
      expect(subject.dialog?).to be false
    end
  end
end
