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

  it "includes Releaf::Builders::Orderer" do
    expect(described_class.ancestors).to include(Releaf::Builders::Orderer)
  end

  describe "#field_names" do
    it "returns field names for object class" do
      allow(Releaf::Core::ResourceFields).to receive(:new).with(object.class).and_call_original
      allow_any_instance_of(Releaf::Core::ResourceFields).to receive(:values).and_return(["a", "b"])
      expect(subject.field_names).to eq(["a", "b"])
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

  describe "#reflect_on_association" do
    it "returns reflection for given reflection name" do
      expect(subject.reflect_on_association(:author)).to eq(object.class.reflections["author"])
    end
  end

  describe "#association_reflector" do
    before do
      resource_fields = subject.resource_fields
      allow(resource_fields).to receive(:association_attributes).with(:x).and_return([:c, :d])

      allow(subject).to receive(:resource_fields).and_return(resource_fields)
      allow(subject).to receive(:sortable_column_name).and_return("sortable column name")
    end

    it "returns association reflector for given reflection" do
      expect(subject.association_reflector(:x, [:a, :b])).to be_instance_of Releaf::Builders::AssociationReflector
    end

    it "pass reflection, fields and sortable column name to association reflector constructor" do
      expect(Releaf::Builders::AssociationReflector).to receive(:new)
        .with(:x, [:a, :b], "sortable column name")
      subject.association_reflector(:x, [:a, :b])
    end

    context "when given fields is nil" do
      it "uses resource fields returned association fields instead" do
        expect(Releaf::Builders::AssociationReflector).to receive(:new)
          .with(:x, [:c, :d], "sortable column name")
        subject.association_reflector(:x, nil)
      end
    end
  end

  describe "#releaf_association_fields" do
    let(:reflector){ Releaf::Builders::AssociationReflector.new(:a, :b, :c) }
    let(:fields){ ["a"] }

    before do
      allow(subject).to receive(:association_reflector).with(:author, fields).and_return(reflector)
      allow(subject).to receive(:releaf_has_many_association).with(reflector).and_return("_has_many_content_")
      allow(subject).to receive(:releaf_belongs_to_association).with(reflector).and_return("_belongs_to_content_")
      allow(subject).to receive(:releaf_has_one_association).with(reflector).and_return("_has_one_content_")
    end

    context "when reflector macro is :has_many" do
      it "renders association with #releaf_has_many_association" do
        allow(reflector).to receive(:macro).and_return(:has_many)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_has_many_content_")
      end
    end

    context "when :belongs_to association given" do
      it "renders association with #releaf_belongs_to_association" do
        allow(reflector).to receive(:macro).and_return(:belongs_to)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_belongs_to_content_")
      end
    end

    context "when :has_one association given" do
      it "renders association with #releaf_has_one_association" do
        allow(reflector).to receive(:macro).and_return(:has_one)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_has_one_content_")
      end
    end

    context "when non implemented assocation type given" do
      it "raises error" do
        allow(reflector).to receive(:macro).and_return(:new_macro_type)
        expect{ subject.releaf_association_fields(:author, fields) }.to raise_error("not implemented")
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

  describe "#releaf_number_field" do
    it "returns input with type 'number'" do
      expect(subject).to receive(:number_field).with("title", { value: nil, step: "any" }).and_return("x")
      expect(subject).to receive(:input_wrapper_with_label).with("title", "x", { label: {}, field: {}, options: { field: { type: "number" }}}).and_return("y")
      expect(subject.releaf_number_field("title")).to eq("y")
    end

    context "aliases" do
      let(:releaf_number_field_method) { subject.method(:releaf_number_field) }

      it "is aliased by #releaf_integer_field" do
        expect(subject.method(:releaf_integer_field)).to eq(releaf_number_field_method)
      end

      it "is aliased by #releaf_float_field" do
        expect(subject.method(:releaf_float_field)).to eq(releaf_number_field_method)
      end

      it "is aliased by #releaf_decimal_field" do
        expect(subject.method(:releaf_decimal_field)).to eq(releaf_number_field_method)
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
          allow(subject).to receive(:object_translation_scope).and_return("xxxx")
          allow(I18n).to receive(:t).with("true_color", scope: "xxxx").and_return("x")
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

  describe "#label_text" do
    it "returns object translation scope `activerecord.attributes._object_class_`" do
      expect(subject.object_translation_scope).to eq("activerecord.attributes.book")
    end
  end

  describe "#sortable_column_name" do
    it "returns 'item_position'" do
      expect( subject.sortable_column_name ).to eq 'item_position'
    end
  end

  describe "#releaf_item_field_collection" do
    context "when collection exists within options" do
      it "returns collection" do
        expect(subject.releaf_item_field_collection(:author_id, collection: "x")).to eq("x")
      end
    end

    context "when collection does not exist within options" do
      it "returns all relation objects" do
        allow(Author).to receive(:all).and_return("y")
        expect(subject.releaf_item_field_collection(:author_id)).to eq("y")
      end
    end
  end

  describe "#releaf_item_field_choices" do
    before do
      subject.object.author_id = 3
    end

    context "when no select_options passed within options" do
      it "prefills select_options with corresponding collection array" do
        collection = [Author.new(name: "a", surname: "b", id: 1), Author.new(name: "c", surname: "d", id: 2)]
        allow(subject).to receive(:releaf_item_field_collection)
          .with(:author_id, x: "a").and_return(collection)
        allow(subject).to receive(:options_for_select).with([["a b", 1], ["c d", 2]], 3).and_return("xx")
        expect(subject.releaf_item_field_choices(:author_id, x: "a")).to eq("xx")
      end
    end

    context "when options have select_options passed" do
      context "when select_options is array" do
        it "process and return select options with `options_for_select` rails helper" do
          collection = [["a b", 1], ["c d", 2]]
          allow(subject).to receive(:options_for_select).with(collection, 3).and_return("xx")
          expect(subject.releaf_item_field_choices(:author_id, select_options: collection)).to eq("xx")
        end
      end

      context "when select_options is not array" do
        it "returns select_options value" do
          expect(subject.releaf_item_field_choices(:author_id, select_options: "xx")).to eq("xx")
        end
      end
    end
  end

  describe "#relation_name" do
    it "strips _id from given string and returns it as symbol" do
      expect(subject.relation_name("admin_id")).to eq(:admin)
    end
  end

  describe "#format_date_or_time_value" do
    context "when given value type is :time" do
      it "format normalized value to default format with `strftime`" do
        value = Date.parse("15 Jan 2015")
        time = Time.parse("15 Jan 2015 12:10:04")
        allow(subject).to receive(:date_or_time_default_format).with(:time).and_return("%H:%M")
        allow(subject).to receive(:normalize_date_or_time_value).with(value, :time).and_return(time)

        expect(subject.format_date_or_time_value(value, :time)).to eq("12:10")
      end
    end

    context "when given value type is other than :time" do
      it "format normalized value to default format  with `I18n.l`" do
        value = Date.parse("15 Jan 2015")
        time = Time.parse("15 Jan 2015 12:10:04")

        allow(subject).to receive(:date_or_time_default_format).with(:date).and_return("_format_")
        allow(subject).to receive(:normalize_date_or_time_value).with(value, :date).and_return(time)
        allow(I18n).to receive(:l).with(time, default: "_format_").and_return("x")
        expect(subject.format_date_or_time_value(value, :date)).to eq("x")


        allow(subject).to receive(:date_or_time_default_format).with(:datetime).and_return("_format_")
        allow(subject).to receive(:normalize_date_or_time_value).with(value, :datetime).and_return(time)
        allow(I18n).to receive(:l).with(time, default: "_format_").and_return("y")
        expect(subject.format_date_or_time_value(value, :datetime)).to eq("y")
      end
    end
  end

  describe "#locales" do
    it "returns object globalize locales" do
      allow(subject.object.class).to receive(:globalize_locales).and_return([:de, :ru])
      expect(subject.locales).to eq([:de, :ru])
    end
  end

  describe "#default_locale" do
    before do
      allow(subject).to receive(:cookies).and_return({})
      allow(I18n).to receive(:locale).and_return(:ru)
      allow(subject).to receive(:locales).and_return([:de, :ru])
    end

    context "when cookies has stored locale" do
      it "returns stored locale normalized to symbol" do
        allow(subject).to receive(:cookies).and_return("releaf.i18n.locale".to_sym => "de")
        expect(subject.default_locale).to eq(:de)
      end
    end

    context "when cookies hasn't stored locale" do
      it "returns current I18n locale" do
        expect(subject.default_locale).to eq(:ru)
      end
    end

    context "when stored locale or I18n locale is not within form locales" do
      it "returns first form locale" do
        allow(subject).to receive(:locales).and_return([:lv, :en])
        expect(subject.default_locale).to eq(:lv)
      end
    end
  end

  describe "#normalize_date_or_time_value" do
    context "when :time type given" do
      it "casts value to time" do
        value = Date.parse("15 Jan 2015")
        expect(subject.normalize_date_or_time_value(value, :time)).to be_instance_of Time
        expect(subject.normalize_date_or_time_value(value, :time)).to eq(value.to_time)
      end
    end

    context "when :datetime type given" do
      it "casts value to datetime" do
        value = Time.parse("15 Jan 2015 12:10:04")
        expect(subject.normalize_date_or_time_value(value, :datetime)).to be_instance_of DateTime
        expect(subject.normalize_date_or_time_value(value, :datetime)).to eq(value.to_datetime)
      end
    end

    context "when :time type given" do
      it "casts value to date" do
        value = DateTime.parse("15 Jan 2015 12:10:04")
        expect(subject.normalize_date_or_time_value(value, :date)).to be_instance_of Date
        expect(subject.normalize_date_or_time_value(value, :date)).to eq(value.to_date)
      end
    end
  end

  describe "#translate_attribute" do
    it "translates given attribute within object translation scope" do
      allow(subject).to receive(:object_translation_scope).and_return("y")
      allow(subject).to receive(:t).with("x", scope: "y").and_return("z")
      expect(subject.translate_attribute("x")).to eq("z")
    end
  end
end
