require "rails_helper"

describe Releaf::Content::Nodes::FormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
    def controller_scope_name; end
    def generate_url_releaf_content_nodes_path(args); end
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Node.new(content_type: "TextPage", slug: "b", id: 2,
                         parent: Node.new(content_type: "TextPage", slug: "a", id: 1)) }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#field_names" do
    it "returns hidden, node and content object fields" do
      expect(subject.field_names).to eq(["node_fields_block", "content_fields_block"])
    end
  end

  describe "#node_fields" do
    it "returns array with renderable node fields" do
      list = [:parent_id, :name, :content_type, :slug, :item_position, :active, :locale]
      expect(subject.node_fields).to eq(list)
    end
  end

  describe "#render_node_fields_block" do
    it "renders node fields" do
      allow(subject).to receive(:node_fields).and_return([1, 2])
      allow(subject).to receive(:releaf_fields).with([1, 2]).and_return("x")
      content = '<div class="section node-fields">x</div>'
      expect(subject.render_node_fields_block).to eq(content)
    end
  end

  describe "#render_parent_id" do
    it "renders hidden parent if field for new object" do
      allow(subject.object).to receive(:new_record?).and_return(true)
      allow(subject).to receive(:hidden_field).with(:parent_id).and_return("x")
      expect(subject.render_parent_id).to eq("x")
    end

    it "renders nothing for existing object" do
      allow(subject.object).to receive(:new_record?).and_return(false)
      expect(subject.render_parent_id).to eq(nil)
    end
  end

  describe "#render_content_fields_block?" do
    before do
      subject.object.build_content
    end

    it "returns array of node content object fields" do
      allow(object.content_class).to receive(:respond_to?).with(:acts_as_node_fields).and_return(true)
      expect(subject.render_content_fields_block?).to be true
    end

    context "when object content class do not respond to `acts_as_node_fields`" do
      it "returns nil" do
        allow(object.content_class).to receive(:respond_to?).with(:acts_as_node_fields).and_return(false)
        expect(subject.render_content_fields_block?).to be false
      end
    end
  end

  describe "#render_content_fields_block" do
    before do
      subject.object.build_content
    end

    it "renders content fields block" do
      allow(subject).to receive(:content_builder_class).and_return("_b_")
      allow(subject).to receive(:render_content_fields_block?).and_return(true)
      subform = described_class.new(:resource, object, template, {})
      allow(subject).to receive(:fields_for).with(:content, subject.object.content, builder: "_b_").and_yield(subform)
      allow(subform).to receive(:field_names).and_return([1, 2])
      allow(subform).to receive(:releaf_fields).with([1, 2]).and_return("yy")
      content = '<div class="section content-fields">yy</div>'
      expect(subject.render_content_fields_block).to eq(content)
    end

    it "casts form fields to array before passign to `releaf_fields`" do
      allow(subject).to receive(:content_builder_class).and_return("_b_")
      allow(subject).to receive(:render_content_fields_block?).and_return(true)
      subform = described_class.new(:resource, object, template, {})
      allow(subject).to receive(:fields_for).with(:content, subject.object.content, builder: "_b_").and_yield(subform)
      allow(subform).to receive(:field_names).and_return({a: 1, b: 2})
      expect(subform).to receive(:releaf_fields).with([[:a, 1], [:b, 2]])
      subject.render_content_fields_block
    end

    context "when content have no fields" do
      it "returns nil" do
        allow(subject).to receive(:render_content_fields_block?).and_return(false)
        expect(subject.render_content_fields_block).to be nil
      end
    end
  end

  describe "#content_builder_class" do
    it "returns `Releaf::Content::Nodes::ContentFormBuilder`" do
      expect(subject.content_builder_class).to eq(Releaf::Content::Nodes::ContentFormBuilder)
    end
  end

  describe "#render_locale" do
    context "when node node has locale select enabled" do
      it "renders locale with #render_locale_options" do
        allow(subject.object).to receive(:locale_selection_enabled?).and_return(true)
        allow(subject).to receive(:render_locale_options).and_return(a: "b")
        allow(subject).to receive(:releaf_item_field).with(:locale, options: {a: "b"}).and_return("x")
        expect(subject.render_locale).to eq("x")
      end
    end

    context "when node node does not have locale select enabled" do
      it "renders locale with #render_locale_options" do
        allow(subject.object).to receive(:locale_selection_enabled?).and_return(false)
        expect(subject.render_locale).to be nil
      end
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
      allow(I18n).to receive(:t).with("text_page", scope: "admin.content_types").and_return("Translated content type")
      allow(subject).to receive(:releaf_text_field).with(:content_type, input: options).and_return("x")
      expect(subject.render_content_type).to eq("x")
    end
  end

  describe "#slug_base_url" do
    before do
      request = double(:request, protocol: "http:://", host_with_port: "somehost:8080")
      allow(subject).to receive(:request).and_return(request)
      allow(object).to receive(:parent).and_return(Node.new)
    end

    context "when trailing slash for path enabled" do
      it "returns absolute url without extra slash added" do
        allow(object).to receive(:trailing_slash_for_path?).and_return(true)
        allow(object.parent).to receive(:path).and_return("/parent/path/")
        expect(subject.slug_base_url).to eq("http:://somehost:8080/parent/path/")
      end
    end

    context "when trailing slash for path disabled" do
      it "returns absolute url with extra slash added" do
        allow(object).to receive(:trailing_slash_for_path?).and_return(false)
        allow(object.parent).to receive(:path).and_return("/parent/path")
        expect(subject.slug_base_url).to eq("http:://somehost:8080/parent/path/")
      end
    end
  end

  describe "#slug_link" do
    before do
      allow(subject).to receive(:slug_base_url).and_return("http://some.host/parent/path/")
    end

    context "when trailing slash for path enabled" do
      it "returns absolute url without extra slash added" do
        allow(object).to receive(:trailing_slash_for_path?).and_return(true)
        expect(subject.slug_link).to eq('<a href="/a/b/">http://some.host/parent/path/<span>b</span>/</a>')
      end
    end

    context "when trailing slash for path disabled" do
      it "returns absolute url with extra slash added" do
        allow(object).to receive(:trailing_slash_for_path?).and_return(false)
        expect(subject.slug_link).to eq('<a href="/a/b">http://some.host/parent/path/<span>b</span></a>')
      end
    end
  end

  describe "#render_slug" do
    it "renders customized field" do
      controller = Admin::NodesController.new
      allow(subject).to receive(:controller).and_return(controller)
      allow(subject).to receive(:slug_base_url).and_return("http://localhost/parent")
      allow(subject).to receive(:url_for).with(controller: "admin/nodes", action: "generate_url", parent_id: 1, id: 2)
        .and_return("http://localhost/slug-generation-url")

      content = '
          <div class="field type-text" data-name="slug">
              <div class="label-wrap">
                  <label for="resource_slug">Slug</label>
              </div>
              <div class="value">
                  <input value="b" class="text" data-generator-url="http://localhost/slug-generation-url" type="text" name="resource[slug]" id="resource_slug" />
                  <button class="button only-icon secondary generate" title="Suggest slug" type="button" autocomplete="off">
                      <i class="fa fa-keyboard-o"></i>
                  </button>
                  <div class="link">
                      <a href="/a/b">http://localhost/parent<span>b</span></a>
                  </div>
             </div>
         </div>
      '

      expect(subject.render_slug).to match_html(content)
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
