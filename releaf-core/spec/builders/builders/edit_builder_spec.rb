require "spec_helper"

describe Releaf::Builders::EditBuilder, type: :class do
  class EditBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  let(:template){ EditBuilderTestHelper.new }
  let(:subject){ described_class.new(template) }

  it "includes Releaf::Builders::View" do
    expect(described_class.ancestors).to include(Releaf::Builders::View)
  end

  it "includes Releaf::Builders::Resource" do
    expect(described_class.ancestors).to include(Releaf::Builders::Resource)
  end

  it "includes Releaf::Builders::Toolbox" do
    expect(described_class.ancestors).to include(Releaf::Builders::Toolbox)
  end

  describe "#form_fields" do
    it "returns form `releaf_fields` output for form `field_names` casted to array" do
      form = Releaf::Builders::FormBuilder.new(:book, Book.new, template, {})
      subject.form = form
      allow(form).to receive(:field_names).and_return({a: 1, b: 2})
      allow(form).to receive(:releaf_fields).with([[:a, 1], [:b, 2]]).and_return(:x)

      expect(subject.form_fields).to eq(:x)
    end
  end
end
