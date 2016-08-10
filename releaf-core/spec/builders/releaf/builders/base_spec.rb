require "rails_helper"

describe Releaf::Builders::Base, type: :module do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ButtonHelper
    include Releaf::ApplicationHelper
    include FontAwesome::Rails::IconHelper
  end
  class BuilderIncluder
    include Releaf::Builders::Base
    attr_accessor :template
  end

  let(:subject){ BuilderIncluder.new }
  let(:template){ FormBuilderTestHelper.new }

  before do
    subject.template = template
  end

  describe "delegations" do
    [:controller, :controller_name, :url_for, :form_for,
     :releaf_button, :params, :form_tag, :file_field_tag,
     :request, :check_box_tag, :label_tag, :content_tag, :hidden_field_tag,
     :render, :link_to, :flash, :truncate, :radio_button_tag,
     :options_for_select, :action_name, :options_from_collection_for_select,
     :select_tag, :text_field_tag,
     :image_tag, :cookies, :button_tag, :merge_attributes
    ].each do|method_name|
      it "deletages #{method_name} to template" do
        expect(subject).to delegate_method(method_name).to(:template)
      end
    end

    [:controller_scope_name, :feature_available?, :builder_class, :index_path].each do|method_name|
      it "delegates #{method_name} to controller" do
        expect(subject).to delegate_method(method_name).to(:controller)
      end
    end
  end

  describe "#layout_settings" do
    it "returns settings manager setting for given key" do
      allow(Releaf.application.config.settings_manager).to receive(:read)
        .with(controller: "_ctrl_", key: "a.x").and_return("xxxxx")
      allow(subject).to receive(:controller).and_return("_ctrl_")

      expect(subject.layout_settings("a.x")).to eq("xxxxx")
    end
  end

  describe "#html_escape" do
    it "escapes given value with " do
      allow(ERB::Util).to receive(:html_escape).with("a").and_return("b")
      expect(subject.html_escape("a")).to eq("b")
    end
  end

  it "aliases #button to #releaf_button" do
    allow(subject.template).to receive(:releaf_button).with("x", a: "y", b: "z").and_return("xx")
    expect(subject.button("x", a: "y", b: "z")).to eq("xx")
  end

  describe "#icon" do
    it "returns template fa_icon output" do
      expect(subject.icon("check")).to eq('<i class="fa fa-check"></i>')
    end
  end

  describe "#tag" do
    context "when block is not given" do
      context "when passing string as content" do
        let(:output) do
          subject.tag(:span, "<p>x</p>", class: "red")
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer

        end

        it "passes all arguments to template #content_tag method and returns properly escaped result" do
          expect( output ).to eq('<span class="red">&lt;p&gt;x&lt;/p&gt;</span>')
        end
      end

      context "when passing safe buffer as content" do
        let(:output) do
          subject.tag(:span, ActiveSupport::SafeBuffer.new("<p>x</p>"), class: "red")
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer

        end

        it "passes all arguments to template #content_tag method and returns properly escaped result" do
          expect( output ).to eq('<span class="red"><p>x</p></span>')
        end
      end

    end

    context "when block is given" do
      context "when block evaluates to array" do
        let(:content) do
          [
            '<p>foo</p>',
            'bar',
            ActiveSupport::SafeBuffer.new('<p>baz</p>')
          ]
        end

        let(:output) do
          subject.tag(:div, class: 'important') { content }
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer
        end

        it "safely joins array" do
          expect( template ).to receive(:safe_join).with(content).and_call_original
          output
        end

        it "passes joined result to #template#content_tag as content" do
          allow( template ).to receive(:safe_join).with(content).and_return('super duper')
          expect( output ).to eq('<div class="important">super duper</div>')
        end

        it "returns properly escaped result" do
          expect( output ).to eq('<div class="important">&lt;p&gt;foo&lt;/p&gt;bar<p>baz</p></div>')
        end

      end

      context "when block evaluates to other than array" do
        let(:output) do
          subject.tag(:div, class: 'important') { '<p>content</p>' }
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer
        end

        it "doesn't call #template#safe_join" do
          expect( template ).to_not receive(:safe_join)
          output
        end

        it "keeps safe buffer unmodified and pass to #template#content_tag as content which won't be escaped" do
          expect( subject.tag(:div, class: 'important') { ActiveSupport::SafeBuffer.new('<p>content</p>') } ).to eq '<div class="important"><p>content</p></div>'
        end

        it "passes block result to #template#content_tag as content which will be escaped" do
          expect( output ).to eq '<div class="important">&lt;p&gt;content&lt;/p&gt;</div>'
        end

        it "casts block result to string" do
          expect( subject.tag(:div, class: 'important') { 1 } ).to eq '<div class="important">1</div>'
        end
      end
    end
  end

  describe "#wrapper" do
    context "when block is given" do
      let(:output) do
        subject.wrapper(class: 'c') do
          '<span class="a">b</span>'.html_safe
        end
      end

      it "wrapps given content within div element with given attributes" do
        expect(output).to eq('<div class="c"><span class="a">b</span></div>')
      end
    end

    context "when block is not given" do
      it "wrapps given content within div element with given attributes" do
        expect(subject.wrapper('<span class="a">b</span>'.html_safe, class: "c")).to eq('<div class="c"><span class="a">b</span></div>')
      end
    end
  end

  describe "#template_variable" do
    it "returns template instance variable value for given key" do
      template.instance_variable_set("@test", "xx")
      expect(subject.template_variable("test")).to eq("xx")
    end
  end

  describe "#safe_join" do
    let(:content) do
      ['foo', '<p>bar</p>', ActiveSupport::SafeBuffer.new('<p>baz</p>')]
    end

    let(:output) do
      subject.safe_join { content }
    end

    it "returns an instance of ActiveSupport::SafeBuffer" do
      expect( output ).to be_a ActiveSupport::SafeBuffer
    end

    it "passes block result to #template#safe_join" do
      expect( template ).to receive(:safe_join).with(content).and_call_original
      output
    end

    it "returns correctly escaped result" do
      expect( output ).to eq 'foo&lt;p&gt;bar&lt;/p&gt;<p>baz</p>'
    end
  end

  describe "#t" do
    before do
      allow(subject).to receive(:default_translation_scope).and_return("_default_scope_")
    end

    it "passes all arguments to I18n.t and returns translation" do
      allow(I18n).to receive(:t).with("x", default: "y", scope: "z").and_return("translated value")
      expect(subject.t("x", default: "y", scope: "z")).to eq("translated value")
    end

    context "when :scope option passed" do
      it "uses default translation scope controller translation scope" do
        expect(I18n).to receive(:t).with("x", scope: "zzz").and_return("asd")
        subject.t("x", scope: "zzz")
      end
    end

    context "when no :scope option passed" do
      it "adds controller translation scope" do
        expect(I18n).to receive(:t).with("x", scope: "_default_scope_").and_return("asd")
        subject.t("x")
      end
    end
  end

  describe "#translate_locale" do
    it "returns translated locale within `locales` scope" do
      allow(subject).to receive(:t).with("de", scope: "locales").and_return("dzerman")
      expect(subject.translate_locale("de")).to eq("dzerman")
    end
  end

  describe "#locale_options" do
    it "returns array with translated locales usable for rails options helper" do
      allow(subject).to receive(:t).with("de", scope: "locales").and_return("dzerman")
      allow(subject).to receive(:t).with("lv", scope: "locales").and_return("latvian")
      expect(subject.locale_options(["de", "lv"])).to eq([["dzerman", "de"], ["latvian", "lv"]])
    end
  end

  describe "#resource_title" do
    it "pass given resource to Releaf::ResourceBase.title and return result" do
      allow(Releaf::ResourceBase).to receive(:title).with("x").and_return("ljhg")
      expect(subject.resource_title("x")).to eq("ljhg")
    end
  end

  describe "#default_translation_scope" do
    it "returns controller scope" do
      controller = Releaf::ActionController.new
      allow(subject).to receive(:controller).and_return(controller)
      allow(controller).to receive(:controller_scope_name).and_return("x")
      expect(subject.default_translation_scope).to eq("x")
    end
  end
end
