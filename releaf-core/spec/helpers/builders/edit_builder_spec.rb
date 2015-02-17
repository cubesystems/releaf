require "spec_helper"

describe Releaf::Builders::EditBuilder, type: :class do
  class EditBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  let(:template){ EditBuilderTestHelper.new }
  let(:subject){ described_class.new(collection, resource_class, template, options) }

  it "includes Releaf::Builders::View" do
    expect(described_class.ancestors).to include(Releaf::Builders::View)
  end

  it "includes Releaf::Builders::Resource" do
    expect(described_class.ancestors).to include(Releaf::Builders::Resource)
  end

  it "includes Releaf::Builders::Toolbox" do
    expect(described_class.ancestors).to include(Releaf::Builders::Toolbox)
  end
end
