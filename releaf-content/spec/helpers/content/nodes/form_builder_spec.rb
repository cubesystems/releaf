require "spec_helper"

describe Releaf::Content::Nodes::FormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
    def controller_scope_name; end
    def generate_url_releaf_content_nodes_path(args); end
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Node.new(content_type: "Text", slug: "b", id: 2,
                         parent: Node.new(content_type: "Text", slug: "a", id: 1)) }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#render_locale" do
    it "renders locale with #render_locale_options" do
      allow(subject).to receive(:render_locale_options).and_return(a: "b")
      allow(subject).to receive(:releaf_item_field).with(:locale, options: {a: "b"}).and_return("x")
      expect(subject.render_locale).to eq("x")
    end
  end

  describe "#render_locale_options" do
    it "returns :select_options and :include_blank values" do
      expect(subject.render_locale_options.keys).to eq([:select_options, :include_blank])
    end

    it ":select_options contains all available locales" do
      allow(I18n).to receive(:available_locales).and_return([:lt, :et])
      expect(subject.render_locale_options[:select_options]).to eq([:lt, :et])
    end

    context "when subject have defined locale" do
      it ":include_blank is false" do
        subject.object.locale = :lt
        expect(subject.render_locale_options[:include_blank]).to be false
      end
    end

    context "when subject have no locale" do
      it ":include_blank is true" do
        subject.object.locale = nil
        expect(subject.render_locale_options[:include_blank]).to be true
      end
    end
  end

  describe "#render_content_type" do
    it "renders disabled content type field with localized content type value" do
      options = {disabled: true, value: "Translated content type"}
      allow(I18n).to receive(:t).with("text", scope: "admin.content_types").and_return("Translated content type")
      allow(subject).to receive(:releaf_text_field).with(:content_type, input: options).and_return("x")
      expect(subject.render_content_type).to eq("x")
    end
  end

  describe "#render_slug" do
    it "renders customized field" do
      controller = Releaf::BaseController.new
      allow(subject).to receive(:controller).and_return(controller)
      allow(subject).to receive(:slug_base_url).and_return("http://localhost/parent")
      allow(subject).to receive(:url_for).with(controller: "/releaf/content/nodes", action: "generate_url", parent_id: 1, id: 2)
        .and_return("http://localhost/slug-generation-url")

      content = '<div class="field type-text" data-name="slug"><div class="label-wrap"><label for="resource_slug">Slug</label></div><div class="value"><input data-generator-url="http://localhost/slug-generation-url" id="resource_slug" name="resource[slug]" type="text" value="b" /><button class="button only-icon secondary generate" title="Suggest slug" type="button"><i class="fa fa-keyboard-o"></i></button><div class="link"><a href="/a/b">http://localhost/parent<span>b</span>/</a></div></div></div>'

      expect(subject.render_slug).to eq(content)
    end
  end

  describe "#render_item_position" do
    it "renders locale with #item_position_options" do
      allow(subject).to receive(:item_position_options).and_return(a: "b")
      allow(subject).to receive(:releaf_item_field).with(:item_position, options: {a: "b"}).and_return("x")
      expect(subject.render_item_position).to eq("x")
    end
  end

  describe "#item_position_options" do
    before do
      object.item_position = 2
      allow(subject).to receive(:item_position_select_options).and_return([["a", 1], ["b", 2], ["c", 3]])
    end

    it "returns :select_options and :include_blank values" do
      expect(subject.item_position_options.keys).to eq([:include_blank, :select_options])
    end

    it ":select_options correct select options" do
      options = '<option value="1">a</option>'
      options << "\n"
      options << '<option selected="selected" value="2">b</option>'
      options << "\n"
      options << '<option value="3">c</option>'
      expect(subject.item_position_options[:select_options]).to eq(options)
    end
  end
end
