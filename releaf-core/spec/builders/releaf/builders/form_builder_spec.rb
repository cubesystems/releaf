require "rails_helper"

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
        subfields: nil
      },
      {
        render_method: "render_author_id",
        field: "author_id",
        subfields: nil
      },
      {
        render_method: "render_chapters",
        field: :chapters,
        subfields: ["title", "text", "sample_html"]
      },
      {
        render_method: "render_book_sequels",
        field: :book_sequels,
        subfields: ["sequel_id"]
      }
    ]
  }

  it "includes Releaf::Builders::Base" do
    expect(described_class.ancestors).to include(Releaf::Builders::Base)
  end

  describe "#field_names" do
    it "returns field names for object class" do
      allow(Releaf::ResourceFields).to receive(:new).with(object.class).and_call_original
      allow_any_instance_of(Releaf::ResourceFields).to receive(:values).and_return(["a", "b"])
      expect(subject.field_names).to eq(["a", "b"])
    end
  end

  describe "#field_type_method" do
    it "returns field type method resolved with ``" do
      allow(Releaf::Builders::Utilities::ResolveAttributeFieldMethodName).to receive(:call)
        .with(object: object, attribute_name: "color").and_return("some_method")
      expect(subject.field_type_method(:color)).to eq("some_method")
    end
  end

  describe "#field_render_method_name" do
    it "returns method name for given field" do
      expect(subject.field_render_method_name(:title)).to eq("render_title")
    end

    context "when builder has parent builder(-s)" do
      it "traverses through all builders and add relation name option to field name" do
        root_builder = described_class.new(:author, Author.new, template, {})
        middle_builder = described_class.new(:author, Author.new, template, {relation_name: :pages, parent_builder: root_builder})
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
        {chapters: ["title", "text", "sample_html"]},
        {book_sequels: ["sequel_id"]}
      ]
      expect(subject.normalize_fields(fields)).to eq(normalized_fields)
    end

    it "handles multi-key hashes" do
      fields = [
        "title",
        "author_id",
        {
          chapters: ["title", "text", "sample_html"],
          book_sequels: ["sequel_id"]
        }
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
      field: "title",
      subfields: [:a, :b],
    } }

    before do
      allow(subject).to receive(:reflect_on_association).with("title").and_return(:x)
      allow(subject).to receive(:sortable_column_name)
        .with(no_args).and_return("_render_method_content_")
      allow(subject).to receive(:releaf_association_fields)
        .with(:x, [:a, :b]).and_return("_association_method_content_")
      allow(subject).to receive(:releaf_field)
        .with("title").and_return("_releaf_field_content_")
    end

    context "when method defined in options[:render_method] exists" do
      it "returns this method output" do
        expect(subject.render_field_by_options(options)).to eq("_render_method_content_")
      end
    end

    context "when custom method does not exist" do
      before do
        options[:render_method] = "something_unexisting"
      end

      context "when reflection exists for given field" do
        it "returns #releaf_association_fields by passing options[:field] and options[:subfields]" do
          expect(subject.render_field_by_options(options)).to eq("_association_method_content_")
        end
      end

      context "when reflection does not exist for given field" do
        it "returns #releaf_field with options[:field] as argument" do
          allow(subject).to receive(:reflect_on_association).with("title").and_return(nil)
          expect(subject.render_field_by_options(options)).to eq("_releaf_field_content_")
        end
      end
    end
  end

  describe "#input_wrapper_with_label" do
    before do
      allow(subject).to receive(:wrapper).with("input_content", class: "value").and_return("input_content")
      allow(subject).to receive(:releaf_label).with(:color, "label_attributes", "options").and_return("label_content")
      allow(subject).to receive(:field).with(:color, "field_attributes", "options"){ |name, field, options, &block|
        expect(block.call).to eq("label_contentinput_content")
      }.and_return("content")
    end

    it "returns wrapped label and input content" do
      expect(subject.input_wrapper_with_label(:color, "input_content", label: "label_attributes", field: "field_attributes", options: "options"))
        .to eq("content")
    end

    context "when block given" do
      it "safely concatinate block output to content" do
        content =  'input_content<input type="hidden" name="book[id]" id="book_id" />'
        allow(subject).to receive(:wrapper).with(content, class: "value").and_return("input_content")
        expect(subject.input_wrapper_with_label(:color, "input_content", label: "label_attributes", field: "field_attributes", options: "options"){ subject.hidden_field(:id) })
          .to eq("content")
      end

      it "correctly handles block nil output" do
        expect(subject.input_wrapper_with_label(:color, "input_content", label: "label_attributes", field: "field_attributes", options: "options"){ })
          .to eq("content")
      end
    end
  end

  describe "#field_attributes" do
    it "adds field data and class attributes and cast name to string within data attributes" do
      expect(subject.field_attributes(:color, {}, {field: {type: "text"}})).to eq(data: {name: "color"}, class: ["field", "type-text"])
    end

    it "merges attributes over build-in data hash" do
      expect(subject.field_attributes(:color, {data: {other: "x"}}, {})[:data]).to eq(name: "color", other: "x")
      expect(subject.field_attributes(:color, {data: {other: "x", name: :lll}}, {})[:data]).to eq(name: :lll, other: "x")
    end

    it "supports class attributes merging" do
      expect(subject.field_attributes(:color, {class: ["a", "b"]}, {})[:class]).to eq(["field", "type-", "a", "b"])
    end
  end

  describe "#input_attributes" do
    it "returns unmodified attributes (allow further override by other builders)" do
      expect(subject.input_attributes(:color, {data: "x"}, {})).to eq(data: "x")
    end
  end

  describe "#sortable_column_name" do
    it "returns 'item_position'" do
      expect( subject.sortable_column_name ).to eq 'item_position'
    end
  end

  describe "#translate_attribute" do
    it "translates given attribute within object translation scope" do
      allow(object.class).to receive(:human_attribute_name).with("x").and_return("z")
      expect(subject.translate_attribute("x")).to eq("z")
    end
  end
end
