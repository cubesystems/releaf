require "spec_helper"

describe Releaf::FormBuilder, type: :class, pending: true do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ described_class.new(:book, object, template, {}) }
  let(:normalized_fields){
    [
      {
        render_method: "render_title",
        field: "title",
        reflection: nil,
        subfields: nil
      },
      {
        render_method: "render_author_id",
        field: "author_id",
        reflection: nil,
        subfields: nil
      },
      {
        render_method: "render_chapters",
        field: :chapters,
        reflection: object.class.reflections[:chapters],
        subfields: ["title", "text", "sample_html"]
      }
    ]
  }

  it "includes Releaf::BuilderCommons" do
    expect(Releaf::FormBuilder.ancestors).to include(Releaf::BuilderCommons)
  end

  describe "#field_render_method_name" do
    it "returns method name for given field" do
      expect(subject.field_render_method_name(:title)).to eq("render_title")
    end

    context "when builder has parent builder" do
      it "traverses through all builders and add relation name option to field name" do
        root_builder = Releaf::FormBuilder.new(:author, Author.new, template, {})
        middle_builder = Releaf::FormBuilder.new(:author, Author.new, template, {relation_name: :pages, parent_builder: root_builder})
        subject.options[:parent_builder] = middle_builder
        subject.options[:relation_name] = :chapters

        expect(subject.field_render_method_name(:title)).to eq("render_pages_chapters_title")
      end
    end
  end

  describe "#normalize_fields" do
    it "returns normalized fields for use with #releaf_fields method" do
      fields = [
        "title",
        "author_id",
        {chapters: ["title", "text", "sample_html"]}
      ]

      expect(subject.normalize_fields(fields)).to eq(normalized_fields)
    end
  end

  describe "#releaf_fields" do
    before do
      @fields = [
        "title",
        "author_id",
        {chapters: ["title", "text", "sample_html"]}
      ]
      allow(subject).to receive(:normalize_fields).with(@fields).and_return(normalized_fields)
    end

    it "normalizes and return rendered output for all fields" do
      allow(subject).to receive(:releaf_field).with("title").and_return("a")
      allow(subject).to receive(:releaf_field).with("author_id").and_return("b")
      allow(subject).to receive(:releaf_field_associations)
        .with(:chapters, object.class.reflections[:chapters], ["title", "text", "sample_html"]).and_return("c")
      expect(subject.releaf_fields(*@fields)).to eq("abc")
    end

    context "when field have custom render method" do
      it "renders field with custom render method" do
        allow(subject).to receive(:render_title).and_return("x")
        allow(subject).to receive(:render_author_id).and_return("y")
        allow(subject).to receive(:render_chapters).and_return("z")
        expect(subject.releaf_fields(*@fields)).to eq("xyz")
      end
    end
  end

  describe "#reflection_skippable_fields" do
    it "returns array with REFLECTION_SKIPPABLE_FIELDS and reflection foreign_key" do
      reflection = object.class.reflections[:chapters]
      allow(reflection).to receive(:foreign_key).and_return("x")
      expect(subject.reflection_skippable_fields(reflection)).to eq(described_class::REFLECTION_SKIPPABLE_FIELDS + ["x"])
    end
  end

  describe "#reflection_subfields" do
    it "returns subfields for reflection" do
      reflection = object.class.reflections[:chapters]
      allow(subject).to receive(:reflection_skippable_fields).with(reflection).and_return([:created_at, :en_title])
      allow(subject).to receive(:reflection_translated_attributes).with(reflection).and_return([:lv_title, :en_title])
      list = ["id", "title", "text", "sample_html", "book_id", "item_position", "created_at", "updated_at", :lv_title]
      expect(subject.reflection_subfields(reflection)).to eq(list)
    end
  end

  describe "#input_wrapper_with_label" do
    it "returns wrapped label and input content" do
      allow(subject).to receive(:releaf_label).with(:color, "label_attributes", "options").and_return("label")
      allow(subject).to receive(:field_attributes).with(:color, "field_attributes", "options").and_return("field_attributes_new")

      allow(subject).to receive(:wrapper).with("input", class: "value").and_return("input")
      allow(subject).to receive(:wrapper).with("labelinput", "field_attributes_new").and_return("content")

      expect(subject.input_wrapper_with_label(:color, "input", label: "label_attributes", field: "field_attributes", options: "options")).to eq("content")
    end
  end

  describe "#wrapper" do
    it "wrapps given content within div element with given attributes" do
      expect(subject.wrapper('<span class="a">b</span>'.html_safe, class: "c")).to eq('<div class="c"><span class="a">b</span></div>')
    end
  end

  describe "#releaf_label" do
    it "passes options :label value to #label_text and use returned value for label text content" do
      allow(subject).to receive(:label_text).with(:color, a: "b").and_return("xx")
      result = '<div class="label_wrap"><label for="author_color">xx</label></div>'

      expect(subject.releaf_label(:color, {}, label: {a: "b"})).to eq(result)
    end

    it "uses #label_attributes for label attributes" do
      allow(subject).to receive(:label_attributes).with(:color, {class: "red"}, {a: "b"}).and_return(class: "red blue")
      result = '<div class="label_wrap"><label class="red blue" for="author_color">Color</label></div>'

      expect(subject.releaf_label(:color, {class: "red"}, {a: "b"})).to eq(result)
    end

    context "when options[:label][:description] is not blank" do
      context "when label has full version" do
        it "includes description" do
          result = '<div class="label_wrap"><label for="author_color">Color</label><div class="description">xxx</div></div>'
          expect(subject.releaf_label(:color, {}, label: {description: "xxx"})).to eq(result)
        end
      end

      context "when label has minimal version" do
        it "does not include description" do
          result = '<label for="author_color">Color</label>'
          expect(subject.releaf_label(:color, {}, label: {minimal: true})).to eq(result)
        end
      end
    end

    context "when options[:label][:minimal] is true" do
      it "returns label tag without wrap element" do
        result = '<label for="author_color">Color</label>'
        expect(subject).to_not receive(:wrapper)
        expect(subject.releaf_label(:color, {}, label: {minimal: true})).to eq(result)
      end
    end

    context "when options[:label][:minimal] is not true" do
      it "returns label tag with wrap element" do
        allow(subject).to receive(:wrapper).with('<label for="author_color">Color</label>', class: "label_wrap").and_return("x")
        expect(subject.releaf_label(:color, {}, label: {minimal: false})).to eq("x")
        expect(subject.releaf_label(:color, {}, label: {minimal: nil})).to eq("x")
        expect(subject.releaf_label(:color, {}, label: {adasd: "xx"})).to eq("x")
      end
    end

  end

  describe "#field_attributes" do
    it "adds field data and class attributes" do
      expect(subject.field_attributes(:color, {}, {field: {type: "text"}})).to eq(data: {name: :color}, class: ["field", "type_text"])
    end

    it "merges attributes over build-in data hash" do
      expect(subject.field_attributes(:color, {data: {other: "x"}}, {})[:data]).to eq(name: :color, other: "x")
      expect(subject.field_attributes(:color, {data: {other: "x", name: :lll}}, {})[:data]).to eq(name: :lll, other: "x")
    end

    it "supports class attributes merging" do
      expect(subject.field_attributes(:color, {class: ["a", "b"]}, {})[:class]).to eq(["field", "type_", "a", "b"])
    end
  end

  describe "#label_attributes" do
    it "returns unmodified attributes (allow further override by other builders)" do
      expect(subject.label_attributes(:color, {data: "x"}, {})).to eq(data: "x")
    end
  end

  describe "#input_attributes" do
    it "returns unmodified attributes (allow further override by other builders)" do
      expect(subject.input_attributes(:color, {data: "x"}, {})).to eq(data: "x")
    end
  end

  describe "#label_text" do
    it "returns model attributes scoped translated value" do
      allow(I18n).to receive(:t).with("color", scope: "activerecord.attributes.book").and_return("x")
      expect(subject.label_text(:color)).to eq("x")
    end

    context "when :label_text option exists" do
      context "when :label_text is not blank" do
        it "returns :label_text option" do
          expect(subject.label_text(:color, label_text: "krāsa")).to eq("krāsa")
        end
      end

      context "when :label_text is blank" do
        it "returns translated value" do
          expect(subject.label_text(:color, label_text: nil)).to eq("Color")
          expect(subject.label_text(:color, label_text: "")).to eq("Color")
        end
      end
    end

    context "when :translation_key option exists" do
      context "when :translation_key is not blank" do
        it "passes :translation_key option to translation and return translated value" do
          allow(I18n).to receive(:t).with("true_color", scope: "activerecord.attributes.book").and_return("x")
          expect(subject.label_text(:color, translation_key: "true_color")).to eq("x")
        end
      end

      context "when :translation_key is blank" do
        it "returns translated value" do
          expect(subject.label_text(:color, translation_key: nil)).to eq("Color")
          expect(subject.label_text(:color, translation_key: "")).to eq("Color")
        end
      end
    end
  end
end
