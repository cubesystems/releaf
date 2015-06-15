require "spec_helper"

describe Releaf::Builders::EditBuilder, type: :class do
  class EditBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    def protect_against_forgery?
      true
    end
    def form_authenticity_token
      "xxx"
    end

    def request_forgery_protection_token
      "yyy"
    end
  end

  let(:template){ EditBuilderTestHelper.new }
  let(:subject){ described_class.new(template) }
  let(:controller){ Releaf::BaseController.new }
  let(:resource){ Book.new }

  before do
    allow(template).to receive(:controller).and_return(controller)
    allow(controller).to receive(:action_name).and_return(:edit)
    allow(subject).to receive(:resource).and_return(resource)
  end

  it "includes Releaf::Builders::View" do
    expect(described_class.ancestors).to include(Releaf::Builders::View)
  end

  it "includes Releaf::Builders::Resource" do
    expect(described_class.ancestors).to include(Releaf::Builders::Resource)
  end

  it "includes Releaf::Builders::Toolbox" do
    expect(described_class.ancestors).to include(Releaf::Builders::Toolbox)
  end

  describe "#section" do
    before do
      allow(subject).to receive(:section_attributes).and_return(a: "b")
      allow(subject).to receive(:form_options).and_return(url: "xxx", builder: Releaf::Builders::FormBuilder)
      allow(subject).to receive(:index_url_preserver).and_return("_index_url_")
      allow(subject).to receive(:section_blocks).and_return(["_section_","_blocks_"])
    end

    it "returns section with index url preserver and section blocks" do
      expect(subject.section).to eq('<section a="b"><form class="new_book" id="new_book" action="xxx" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="yyy" value="xxx" />_index_url__section__blocks_</form></section>')
    end

    it "assigns form instance to builder" do
      expect{ subject.section }.to change{ subject.form }.from(nil)
      expect(subject.form).to be_instance_of Releaf::Builders::FormBuilder
    end
  end

  describe "#form_options" do
    it "returns controller form options for current action and resource" do
      allow(controller).to receive(:form_options).with(:edit, resource, :resource).and_return(:y)
      expect(subject.form_options).to eq(:y)
    end
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
