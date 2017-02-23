require "rails_helper"

describe Releaf::Builders::EditBuilder, type: :class do
  class TranslationsEditBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper

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
  let(:controller){ Releaf::ActionController.new }
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
      allow(subject).to receive(:index_path_preserver).and_return("_index_path_")
      allow(subject).to receive(:section_blocks).and_return(["_section_","_blocks_"])
    end

    it "returns section with index url preserver and section blocks" do
      expect(subject.section_content).to eq('<form class="new_book" id="new_book" action="xxx" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="yyy" value="xxx" />_index_path__section__blocks_</form>')
    end

    it "assigns form instance to builder" do
      expect{ subject.section_content }.to change{ subject.form }.from(nil)
      expect(subject.form).to be_instance_of Releaf::Builders::FormBuilder
    end
  end

  describe "#index_path_preserver" do
    it "returns hidden index url input" do
      allow(subject).to receive(:params).and_return(index_path: "?asd=23&lf=dd")
      result = '<input type="hidden" name="index_path" id="index_path" value="?asd=23&amp;lf=dd" />'
      expect(subject.index_path_preserver).to eq(result)
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
      allow(subject).to receive(:error_notices_header).and_return("<error_notice_header />".html_safe)
    end

    context "when errors exists" do

      it "returns errors block" do
        resource.valid?

        expect(subject.error_notices).to match_html(%Q[
          <div class="form-error-box">
              <error_notice_header />
              <ul>
                <li class="error">Title can&#39;t be blank</li>
              </ul>
          </div>
        ])
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
    before do
      allow(subject).to receive(:save_button).and_return("_svbtn_")
      allow(subject).to receive(:save_and_create_another_button).and_return("_svacrbtn_")
    end

    context "when create_another is availble" do
      it "returns an array with save_and_create_another and save buttons" do
        allow(subject).to receive(:create_another_available?).and_return true
        expect(subject.footer_primary_tools).to eq(["_svacrbtn_", "_svbtn_"])
      end
    end

    context "when create_another is not available" do
      it "returns an array with save button" do
        allow(subject).to receive(:create_another_available?).and_return false
        expect(subject.footer_primary_tools).to eq(["_svbtn_"])
      end
    end

  end

  describe "#create_another_available?" do
    context "when editing an existing record" do
      let(:resource){ FactoryGirl.create(:book) }

      context "when controller has create_another feature enabled" do
        it "returns false" do
          expect(subject.create_another_available?).to be false
        end
      end

      context "when controller has create_another feature disabled" do
        it "returns false" do
          expect(subject.create_another_available?).to be false
        end
      end
    end

    context "when creating a new record" do
      context "when controller has create_another feature enabled" do
        it "returns true" do
          expect(subject.create_another_available?).to be true
        end
      end

      context "when controller has create_another feature disabled" do
        it "returns false" do
          allow(controller).to receive(:feature_available?).with(:create_another).and_return false
          expect(subject.create_another_available?).to be false
        end
      end
    end

    context "when resource is not present" do
      let(:resource){ nil }
      it "returns false" do
        expect(subject.create_another_available?).to be false
      end
    end

  end

  describe "#save_and_create_another_button" do
    it "returns save and create button" do
      allow(template).to receive(:fa_icon).with("plus").and_return('<plus_icon />'.html_safe)
      allow(subject).to receive(:t).with("Save and create another").and_return("Save and ccrr")
      expect(subject.save_and_create_another_button).to match_html(%Q[
          <button class="button with-icon secondary" title="Save and ccrr" type="submit" autocomplete="off" name="after_save" value="create_another" data-type="ok" data-disable="true">
              <plus_icon />
              Save and ccrr
          </button>
      ])
    end
  end

  describe "#form_options" do
    it "returns form options" do
      allow(subject).to receive(:form_builder_class).and_return("CustomFormBuilderClassHere")
      allow(subject).to receive(:form_url).and_return("/some-url-here")
      allow(subject).to receive(:form_attributes).and_return(some: "options_here")
      allow(subject).to receive(:resource_name).and_return(:author)

      options = {
        builder: "CustomFormBuilderClassHere",
        as: :author,
        url: "/some-url-here",
        html: {some: "options_here"}
      }
      expect(subject.form_options).to eq(options)
    end
  end

  describe "#form_url" do
    it "returns form url built from form action and resource id" do
      resource.id = 23
      allow(subject).to receive(:form_action).and_return("upd")
      allow(subject).to receive(:url_for).with(action: "upd", id: 23).and_return("/res/new")
      expect(subject.form_url).to eq("/res/new")
    end
  end

  describe "#form_action" do
    context "when new resource" do
      it "returns `create`" do
        allow(resource).to receive(:new_record?).and_return(true)
        expect(subject.form_action).to eq("create")
      end
    end

    context "when persisted resource" do
      it "returns `update`" do
        allow(resource).to receive(:new_record?).and_return(false)
        expect(subject.form_action).to eq("update")
      end
    end
  end

  describe "#resource_name" do
    it "returns `:resource`" do
      expect(subject.resource_name).to eq(:resource)
    end
  end

  describe "#form_url" do
    it "returns form builder class" do
      allow(subject).to receive(:builder_class).with(:form).and_return("x")
      expect(subject.form_builder_class).to eq("x")
    end
  end

  describe "#form_identifier" do
    before do
      allow(subject).to receive(:resource_name).and_return(:book)
    end

    context "when resource has persistance check method and it's persisted" do
      it "returns resource name prefixed with `edit-`" do
        allow(resource).to receive(:persisted?).and_return(true)
        expect(subject.form_identifier).to eq("edit-book")
      end
    end

    context "when resource has persistance check method and it's not persisted" do
      it "returns resource name prefixed with `new-`" do
        allow(resource).to receive(:persisted?).and_return(false)
        expect(subject.form_identifier).to eq("new-book")
      end
    end

    context "when resource has no persistance check method" do
      it "returns resource name prefixed with `update-`" do
        allow(subject).to receive(:resource).and_return(String.new)
        expect(subject.form_identifier).to eq("edit-book")
      end
    end
  end

  describe "#form_classes" do
    before do
      allow(subject).to receive(:form_identifier).and_return("xx")
    end

    it "returns array with form identifier" do
      expect(subject.form_classes).to eq(["xx"])
    end

    context "when object has any errors" do
      it "adds has-error class to returned array" do
        resource.title = nil
        resource.valid?
        expect(subject.form_classes).to eq(["xx", "has-error"])
      end
    end
  end

  describe "#form_attributes" do
    it "returns form attributes" do
      allow(subject).to receive(:form_identifier).and_return("xx")
      allow(subject).to receive(:form_classes).and_return(["a", "b"])

      attributes = {
         multipart: true,
         novalidate: "",
         class: ["a", "b"],
         id: "xx",
         data: {
           "remote"=>true,
           "remote-validation"=>true,
           "type"=>:json
         }
      }
      expect(subject.form_attributes).to eq(attributes)
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
