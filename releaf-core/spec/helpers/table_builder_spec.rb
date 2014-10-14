require "spec_helper"

describe Releaf::TableBuilder, type: :class, pending: true do
  class TableBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Book }
  let(:subject){ described_class.new(Book.all, resource_class, template, {}) }

  it "includes Releaf::BuilderCommons" do
    expect(Releaf::TableBuilder.ancestors).to include(Releaf::BuilderCommons)
  end
end
