require "spec_helper"

describe Releaf::Builders::FormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ described_class.new(:book, object, template, {}) }
  let(:normalized_fields){
    [
      {
        render_method: "render_title",
        field: "title",
        association: false,
        subfields: nil
      },
      {
        render_method: "render_author_id",
        field: "author_id",
        association: false,
        subfields: nil
      },
      {
        render_method: "render_chapters",
        field: :chapters,
        association: true,
        subfields: ["title", "text", "sample_html"]
      }
    ]
  }

  it "includes Releaf::Builders::Base" do
    expect(Releaf::Builders::TableBuilder.ancestors).to include(Releaf::Builders::Base)
  end

  it "includes Releaf::Builders::ResourceClass" do
    expect(Releaf::Builders::TableBuilder.ancestors).to include(Releaf::Builders::ResourceClass)
  end

  describe "#field_names" do
    it "returns field names for object class" do
      allow(subject).to receive(:resource_class_attributes).with(object.class).and_return(["a", "b"])
      expect(subject.field_names).to eq(["a", "b"])
    end
  end

  describe "#field_render_method_name" do
    it "returns method name for given field" do
      expect(subject.field_render_method_name(:title)).to eq("render_title")
    end

    context "when builder has parent builder(-s)" do
      it "traverses through all builders and add relation name option to field name" do
        root_builder = Releaf::Builders::FormBuilder.new(:author, Author.new, template, {})
        middle_builder = Releaf::Builders::FormBuilder.new(:author, Author.new, template, {relation_name: :pages, parent_builder: root_builder})
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
    it "normalizes given fields with #normalize_fields" do
      allow(subject).to receive(:render_field_by_options)
      expect(subject).to receive(:normalize_fields).with([:a, :b]).and_return([:x, :y])
      subject.releaf_fields(:a, :b)
    end

    it "passes all normalized field options to #render_field" do
      allow(subject).to receive(:normalize_fields).and_return([:x, :y])
      expect(subject).to receive(:render_field_by_options).with(:x)
      expect(subject).to receive(:render_field_by_options).with(:y)
      subject.releaf_fields(:a, :b)
    end

    it "concatenates and return all #render_field_by_options outputs with #safe_join" do
      allow(subject).to receive(:render_field_by_options).and_return('_a_', '_b_')
      allow(subject).to receive(:normalize_fields).and_return([:x, :y])
      expect(subject).to receive(:safe_join).with(no_args){|&block|
        expect(block.call).to eq(['_a_', '_b_'])
      }.and_return("xxx")
      expect(subject.releaf_fields(:a, :b)).to eq("xxx")
    end
  end

  describe "#render_field_by_options" do
    let(:options){ {
      render_method: "sortable_column_name", # just random method here
      association: nil,
      field: "title",
      subfields: [:a, :b],
      association: true
    } }

    before do
      allow(subject).to receive(:sortable_column_name)
        .with(no_args).and_return("_render_method_content_")
      allow(subject).to receive(:releaf_association_fields)
        .with("title", [:a, :b]).and_return("_association_method_content_")
      allow(subject).to receive(:releaf_field)
        .with("title").and_return("_releaf_field_content_")
    end

    context "when method defined in options[:render_method] exists" do
      it "returns this method output" do
        expect(subject.render_field_by_options(options)).to eq("_render_method_content_")
      end
    end

    context "when custom method does not exists and options[:association] is true" do
      it "returns #releaf_association_fields by passing options[:field] and options[:subfields]" do
        options[:render_method] = "something_unexisting"
        expect(subject.render_field_by_options(options)).to eq("_association_method_content_")
      end
    end

    context "when neither custom method exists or association is presented" do
      it "returns #releaf_field with options[:field] as argument" do
        options[:association] = false
        options[:render_method] = "something_unexisting"
        expect(subject.render_field_by_options(options)).to eq("_releaf_field_content_")
      end
    end
  end

  describe "#reflection" do
    it "returns reflection for given reflection name" do
      expect(subject.reflection("author")).to eq(object.class.reflections[:author])
    end
  end

  describe "#association_fields" do
    it "returns association field names except foreign key by given association name" do
      fields = ["name", "surname", "bio", "birth_date", "wiki_link"]
      expect(subject.association_fields("author")).to eq(fields)
    end
  end

  describe "#releaf_association_fields" do
    let(:reflection){ instance_double(ActiveRecord::Reflection::AssociationReflection) }
    let(:fields){ ["a"] }

    before do
      allow(subject).to receive(:reflection).with(:author).and_return(reflection)
      allow(subject).to receive(:association_fields).with(:author).and_return(["b"])
      allow(subject).to receive(:releaf_has_many_association).with(:author, fields).and_return("_has_many_content_")
      allow(subject).to receive(:releaf_belongs_to_association).with(:author, fields).and_return("_belongs_to_content_")
    end

    context "when given fields argument is nil" do
      it "passes #association_fields returned fields" do
        allow(reflection).to receive(:macro).and_return(:has_many)
        allow(subject).to receive(:releaf_has_many_association).with(:author, ["b"]).and_return("_has_many_content_")
        expect(subject.releaf_association_fields(:author, nil)).to eq("_has_many_content_")
      end
    end

    context "when :has_many association given" do
      it "renders association with #releaf_has_many_association" do
        allow(reflection).to receive(:macro).and_return(:has_many)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_has_many_content_")
      end
    end

    context "when :belongs_to association given" do
      it "renders association with #releaf_belongs_to_association" do
        allow(reflection).to receive(:macro).and_return(:belongs_to)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_belongs_to_content_")
      end
    end

    context "when non implemented assocation type given" do
      it "raises error" do
        allow(reflection).to receive(:macro).and_return(:new_macro_type)
        expect{ subject.releaf_association_fields(:author, fields) }.to raise_error("not implemented")
      end
    end
  end

  describe "#input_wrapper_with_label" do
    it "returns wrapped label and input content" do
      allow(subject).to receive(:releaf_label).with(:color, "label_attributes", "options").and_return("label_content")
      allow(subject).to receive(:wrapper).with("input_content", class: "value").and_return("input_content")

      allow(subject).to receive(:field).with(:color, "field_attributes", "options"){ |name, field, options, &block|
        expect(block.call).to eq("label_contentinput_content")
      }.and_return("content")

      expect(subject.input_wrapper_with_label(:color, "input_content", label: "label_attributes", field: "field_attributes", options: "options"))
        .to eq("content")
    end
  end

  describe "#releaf_label" do
    it "passes options :label value to #label_text and use returned value for label text content" do
      allow(subject).to receive(:label_text).with(:color, a: "b").and_return("xx")
      result = '<div class="label-wrap"><label for="book_color">xx</label></div>'

      expect(subject.releaf_label(:color, {}, label: {a: "b"})).to eq(result)
    end

    it "uses #label_attributes for label attributes" do
      allow(subject).to receive(:label_attributes).with(:color, {class: "red"}, {a: "b"}).and_return(class: "red blue")
      result = '<div class="label-wrap"><label class="red blue" for="book_color">Color</label></div>'

      expect(subject.releaf_label(:color, {class: "red"}, {a: "b"})).to eq(result)
    end

    context "when options[:label][:description] is not blank" do
      context "when label has full version" do
        it "includes description" do
          result = '<div class="label-wrap"><label for="book_color">Color</label><div class="description">xxx</div></div>'
          expect(subject.releaf_label(:color, {}, label: {description: "xxx"})).to eq(result)
        end
      end

      context "when label has minimal version" do
        it "does not include description" do
          result = '<label for="book_color">Color</label>'
          expect(subject.releaf_label(:color, {}, label: {minimal: true})).to eq(result)
        end
      end
    end

    context "when options[:label][:minimal] is true" do
      it "returns label tag without wrap element" do
        result = '<label for="book_color">Color</label>'
        expect(subject).to_not receive(:wrapper)
        expect(subject.releaf_label(:color, {}, label: {minimal: true})).to eq(result)
      end
    end

    context "when options[:label][:minimal] is not true" do
      it "returns label tag with wrap element" do
        allow(subject).to receive(:wrapper).with('<label for="book_color">Color</label>', class: "label-wrap").and_return("x")
        expect(subject.releaf_label(:color, {}, label: {minimal: false})).to eq("x")
        expect(subject.releaf_label(:color, {}, label: {minimal: nil})).to eq("x")
        expect(subject.releaf_label(:color, {}, label: {adasd: "xx"})).to eq("x")
      end
    end

  end

  describe "#field_attributes" do
    it "adds field data and class attributes" do
      expect(subject.field_attributes(:color, {}, {field: {type: "text"}})).to eq(data: {name: :color}, class: ["field", "type-text"])
    end

    it "merges attributes over build-in data hash" do
      expect(subject.field_attributes(:color, {data: {other: "x"}}, {})[:data]).to eq(name: :color, other: "x")
      expect(subject.field_attributes(:color, {data: {other: "x", name: :lll}}, {})[:data]).to eq(name: :lll, other: "x")
    end

    it "supports class attributes merging" do
      expect(subject.field_attributes(:color, {class: ["a", "b"]}, {})[:class]).to eq(["field", "type-", "a", "b"])
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

  describe "#sortable_column_name" do
    it "returns 'item_position'" do
      expect( subject.sortable_column_name ).to eq 'item_position'
    end
  end

  describe "#releaf_checkbox_group" do
    it "renders checkbox group" do
      allow(subject).to receive(:releaf_checkbox_group_content)
        .with(:tags, ["a", "b"]).and_return('a_&quot;_ab_"_b'.html_safe)
      content = '<div class="field type-boolean-group" data-name="tags"><div class="label-wrap"><label for="book_tags">Tags</label></div><div class="value">a_&quot;_ab_"_b</div></div>'

      expect(subject.releaf_checkbox_group(:tags, options: {items: ["a", "b"]})).to eq(content)
    end
  end

  describe "#releaf_checkbox_group_content" do
    it "returns rendered checkbox group items" do
      allow(subject).to receive(:releaf_checkbox_group_item).with(:tags, "a").and_return('a_"_a')
      allow(subject).to receive(:releaf_checkbox_group_item).with(:tags, "b").and_return('b_"_b'.html_safe)
      content = 'a_&quot;_ab_"_b'
      expect(subject.releaf_checkbox_group_content(:tags, ["a", "b"])).to eq(content)
    end
  end

  describe "#releaf_checkbox_group_item" do
    let(:object){ Releaf::Permissions::Role.new }
    it "renders single checkbox group checkbox" do
      content = '<div class="type-boolean-group-item"><input id="book_permissions_a" name="book[permissions][]" type="checkbox" value="a" /><label for="book_permissions_a">x</label></div>'
      expect(subject.releaf_checkbox_group_item(:permissions, label: "x", value: "a"))
        .to eq(content)

      object.permissions = ["a"]
      content = '<div class="type-boolean-group-item"><input checked="checked" id="book_permissions_a" name="book[permissions][]" type="checkbox" value="a" /><label for="book_permissions_a">x</label></div>'
      expect(subject.releaf_checkbox_group_item(:permissions, label: "x", value: "a"))
        .to eq(content)
    end
  end
end
