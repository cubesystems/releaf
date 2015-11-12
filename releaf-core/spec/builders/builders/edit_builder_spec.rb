require "rails_helper"

describe Releaf::Builders::EditBuilder, type: :class do
  class TranslationsEditBuilderTestHelper < ActionView::Base
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

  let(:template){ TranslationsEditBuilderTestHelper.new }
  let(:subject){ described_class.new(template) }
  let(:controller){ Releaf::BaseController.new }
  let(:resource){ Book.new }

  before do
    allow(template).to receive(:controller).and_return(controller)
    allow(controller).to receive(:action_name).and_return(:edit)
    allow(subject).to receive(:resource).and_return(resource)
  end

  describe "#section_content" do
    before do
      allow(subject).to receive(:section_attributes).and_return(a: "b")
      allow(subject).to receive(:form_options).and_return(url: "xxx", builder: Releaf::Builders::FormBuilder)
      allow(subject).to receive(:index_url_preserver).and_return("_index_url_")
      allow(subject).to receive(:section_blocks).and_return(["_section_","_blocks_"])
    end

    it "returns section with index url preserver and section blocks" do
      expect(subject.section_content).to eq('<form class="new_book" id="new_book" action="xxx" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="yyy" value="xxx" />_index_url__section__blocks_</form>')
    end

    it "assigns form instance to builder" do
      expect{ subject.section_content }.to change{ subject.form }.from(nil)
      expect(subject.form).to be_instance_of Releaf::Builders::FormBuilder
    end
  end

  describe "#index_url_preserver" do
    it "returns hidden index url input" do
      allow(subject).to receive(:params).and_return(index_url: "?asd=23&lf=dd")
      result = '<input type="hidden" name="index_url" id="index_url" value="?asd=23&amp;lf=dd" />'
      expect(subject.index_url_preserver).to eq(result)
    end
  end

  describe "#section_body_blocks" do
    it "returns array with error notices and form fields" do
      allow(subject).to receive(:error_notices).and_return("err")
      allow(subject).to receive(:form_fields).and_return("fields")
      expect(subject.section_body_blocks).to eq(["err", "fields"])
    end
  end

  describe "#error_notices" do
    before do
      allow(subject).to receive(:error_notices_header).and_return(ActiveSupport::SafeBuffer.new("x"))
    end

    context "when errors exists" do
      it "returns errors block" do
        resource.valid?
        expect(subject.error_notices).to eq('<div id="error_explanation">x<ul><li>Title Blank</li></ul></div>')
      end
    end

    context "when no errors present" do
      it "returns nil" do
        expect(subject.error_notices).to be nil
      end
    end
  end

  describe "#error_notices_header" do
    it "returns validation errors notices header" do
      resource.valid?
      expect(subject.error_notices_header).to eq('<strong>1 validation error occured:</strong>')

      resource.title = "xx"
      resource.valid?
      expect(subject.error_notices_header).to eq('<strong>0 validation errors occured:</strong>')
    end
  end

  describe "#footer_primary_tools" do
    it "returns array with save button" do
      allow(subject).to receive(:save_button).and_return("_svbtn_")
      expect(subject.footer_primary_tools).to eq(["_svbtn_"])
    end
  end

  describe "#save_button" do
    it "returns save button" do
      allow(subject).to receive(:button)
        .with("to_list", "check", {class: "primary", data: {type: "ok", disable: true}, type: "submit"})
        .and_return("_btn_")
      allow(subject).to receive(:t).with("Save").and_return("to_list")
      expect(subject.save_button).to eq("_btn_")
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
