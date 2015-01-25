require "spec_helper"

describe Releaf::Builders::TableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base
    include Releaf::ToolboxHelper
    include Releaf::ApplicationHelper
  end

  class DummyTableBuilderInheriter < Releaf::Builders::TableBuilder
    def some_cell_method(resource, column); end
    def custom_format(resource, column); end
    def format_big_boolean_content(resource, column); end
    def title_cell; end
    def custom_title(resource); end
  end

  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Book }
  let(:resource){ resource_class.new(id: 77) }
  let(:collection){ Book.all }
  let(:options){ {toolbox: false} }
  let(:subject){ described_class.new(collection, resource_class, template, options) }
  let(:inheriter_subject){ DummyTableBuilderInheriter.new(collection, resource_class, template, options) }

  it "includes Releaf::Builders::Base" do
    expect(Releaf::Builders::TableBuilder.ancestors).to include(Releaf::Builders::Base)
  end

  describe "#initialize" do
    it "assigns collection" do
      expect(subject.collection.to_sql).to eq(collection.to_sql)
    end

    it "assigns resource_class" do
      expect(subject.resource_class).to eq(resource_class)
    end

    it "assigns template" do
      expect(subject.template).to eq(template)
    end

    it "assigns options" do
      expect(subject.options).to eq(options)
    end
  end

  describe "#columns" do
    it "returns columns schema" do
      allow(subject).to receive(:columns_schema).and_return("schema")
      expect(subject.columns).to eq("schema")
    end

    it "caches columns schema data" do
      expect(subject).to receive(:columns_schema).and_return("schema").once
      subject.columns
      subject.columns
    end
  end

  describe "#column_names" do
    it "returns column names for resource_class" do
      allow(Releaf::Core::ResourceFields).to receive(:new).with(subject.resource_class).and_call_original
      allow_any_instance_of(Releaf::Core::ResourceFields).to receive(:values)
        .with(include_associations: false).and_return(["a", "b"])
      expect(subject.column_names).to eq(["a", "b"])
    end
  end

  describe "#columns_schema" do
    before do
      allow(subject).to receive(:column_names).and_return([:price, :title, :author_id])
      allow(subject).to receive(:cell_content_method).with(:price).and_return(:title_content)
      allow(subject).to receive(:cell_content_method).with(:title).and_return(:title_content)
      allow(subject).to receive(:cell_content_method).with(:author_id).and_return(nil)
      allow(subject).to receive(:cell_format_method).with(:author_id).and_return(:some_text_format)
    end

    it "returns hash with columns and corresponding method" do
      allow(subject).to receive(:cell_method).with(:price).and_return("price_cell")
      allow(subject).to receive(:cell_method).with(:title).and_return(nil)
      allow(subject).to receive(:cell_method).with(:author_id).and_return(nil)
      columns = {
        price: {cell_method: "price_cell"},
        title: {content_method: :title_content},
        author_id: {format_method: :some_text_format}
      }
      expect(subject.columns_schema).to eq(columns)
    end

    it "preserves order as in #column_names" do
      expect(subject.columns_schema.keys).to eq([:price, :title, :author_id])
    end

    context "when options[:toolbox] value is 'true'" do
      let(:options){ {toolbox: true} }
      it "adds toolbox as first column" do
        expect(subject.columns_schema.keys.first).to eq(:toolbox)
      end

      it "uses #toolbox_cell for toolbox cell rendering" do
        expect(subject.columns_schema[:toolbox]).to eq(cell_method: "toolbox_cell")
      end
    end
  end

  describe "#output" do
    before do
      allow(subject).to receive(:empty_body).and_return("empty")
    end

    it "returns table with #empty_body content" do
      allow(subject).to receive(:table_attributes).and_return(class: "a", data: {some: "b"})
      content = '<table class="a" data-some="b">empty</table>'
      expect(subject.output).to eq(content)
    end

    context "when collection is not empty" do
      it "returns table with #header and #body" do
        create(:book)
        content = '<table class="table books">header_contentbody_content</table>'
        allow(subject).to receive(:head).and_return("header_content")
        allow(subject).to receive(:body).and_return("body_content")

        expect(subject.output).to eq(content)
      end
    end

    context "when collection is empty" do
      it "returns table with #empty_body content" do
        content = '<table class="table books">empty</table>'
        expect(subject.output).to eq(content)
      end
    end
  end

  describe "#table_attributes" do
    it "returns hash with table and pluralized, dasherized resource classes" do
      expect(subject.table_attributes).to eq(class: ["table", "books"])
    end
  end

  describe "#head" do
    it "returns header row with #head_cell generated cells for each columns" do
      allow(subject).to receive(:column_names).and_return([:price, :title, :author_id])
      allow(subject).to receive(:head_cell).with(:price).and_return("_price_cell_")
      allow(subject).to receive(:head_cell).with(:title).and_return("_title_cell_")
      allow(subject).to receive(:head_cell).with(:author_id).and_return("_author_id_cell_")

      content = '<thead><tr>_price_cell__title_cell__author_id_cell_</tr></thead>'
      expect(subject.head).to eq(content)
    end
  end

  describe "#head_cell" do
    it "returns 'th' element with content from #head_cell_column" do
      allow(subject).to receive(:head_cell_content).with(:title).and_return("_title_content_")
      content = '<th>_title_content_</th>'
      expect(subject.head_cell(:title)).to eq(content)
    end
  end

  describe "#head_cell_content" do
    it "returns resource class attributes scoped translated column value within span element" do
      allow(I18n).to receive(:t).with("title", scope: "activerecord.attributes.book").and_return("Taittls")
      expect(subject.head_cell_content(:title)).to eq('<span>Taittls</span>')
    end

    context "when column value is 'toolbox'" do
      it "returns nil" do
        expect(subject.head_cell_content(:toolbox)).to eq(nil)
      end
    end
  end

  describe "#empty_body" do
    it "returns empty table body content" do
      content = '<tr><th><div class="nothing-found">Nothing found</div></th></tr>'
      expect(subject.empty_body).to eq(content)
    end
  end

  describe "#body" do
    it "returns table body with rows for each collection items generated with #row method" do
      subject.collection = ["a", "b"]
      allow(subject).to receive(:row).with("a").and_return("_a_row_")
      allow(subject).to receive(:row).with("b").and_return("_b_row_")

      content = '<tbody class="tbody">_a_row__b_row_</tbody>'
      expect(subject.body).to eq(content)
    end
  end

  describe "#row_url" do
    it "returns edit url for given resource" do
      template = double("some template")
      allow(template).to receive(:resource_edit_url).with("a").and_return('_url_')
      allow(subject).to receive(:template).and_return(template)
      expect(subject.row_url("a")).to eq('_url_')
    end

    context "when resource do not have edit route/url" do
      it "returns nil" do
        expect(subject.row_url("a")).to eq(nil)
      end
    end
  end

  describe "#row_attributes" do
    it "returns row attributes with html class and resource id as data value" do
      resource = resource_class.new(id: 77)
      expect(subject.row_attributes(resource)).to eq(class: "row", data: {id: 77})
    end
  end

  describe "#row" do
    it "adds attributes returned from #row_attributes to row" do
      resource = resource_class.new
      allow(subject).to receive(:column_names).and_return([])
      allow(subject).to receive(:row_attributes).with(resource).and_return(class: "color", data: {color: "red"})

      content = '<tr class="color" data-color="red"></tr>'
      expect(subject.row(resource)).to eq(content)
    end

    it "calls #row_url only once" do
      resource = resource_class.new
      allow(subject).to receive(:column_names).and_return([:title, :author_id])
      expect(subject).to receive(:row_url).with(resource).once
      subject.row(resource)
    end

    it "output each cell contents by using either custom or default cell method" do
      columns = {
        title: {cell_method: "some_cell_method"},
        color: {},
      }
      resource = resource_class.new(id: 89)

      allow(inheriter_subject).to receive(:columns).and_return(columns)
      allow(inheriter_subject).to receive(:row_url).with(resource).and_return("url_value")

      allow(inheriter_subject).to receive(:some_cell_method)
        .with(resource, cell_method: "some_cell_method", url: "url_value").and_return("_title_cell_value")
      allow(inheriter_subject).to receive(:cell)
        .with(resource, :color, url: "url_value").and_return("_color_cell_value")

      content = '<tr class="row" data-id="89">_title_cell_value_color_cell_value</tr>'
      expect(inheriter_subject.row(resource)).to eq(content)
    end
  end

  describe "#cell_content" do
    it "returns format method output with resource and column as arguments wrapped in span element" do
      options = {format_method: "custom_format"}
      allow(inheriter_subject).to receive(:custom_format).with("a", :title).and_return('_custom " format_')

      content = '<span>_custom &quot; format_</span>'
      expect(inheriter_subject.cell_content("a", :title, options)).to eq(content)
    end

    context "when given options has :content_method" do
      it "returns content method output with resource as argument wrapped in span element" do
        options = {content_method: "custom_title", format_method: "custom_format"}
        allow(inheriter_subject).to receive(:custom_title).with("a").and_return('_custom " _value_')

        content = '<span>_custom &quot; _value_</span>'
        expect(inheriter_subject.cell_content("a", :title, options)).to eq(content)
      end
    end
  end

  describe "#format_text_content" do
    it "returns truncated and escape column value" do
      text = '"Pra<tag>nt commodo cursus magn'
      resource = resource_class.new(title: text)
      content = '&quot;Pra&lt;tag&gt;nt commodo cursus magn'

      expect(subject.format_text_content(resource, :title)).to eq(content)
    end

    it "casts value to string before truncation" do
      resource = resource_class.new(title: nil)
      expect(subject.format_text_content(resource, :title)).to eq("")
    end
  end

  describe "#format_string_content" do
    context "when resource column value respond to #to_text method" do
      it "returns value #to_text" do
        fake_obj = double
        allow(fake_obj).to receive(:to_text).and_return("nineninine")
        resource = resource_class.new(id: 99)
        allow(resource).to receive(:id).and_return(fake_obj)

        expect(subject.format_string_content(resource, :id)).to eq("nineninine")
      end
    end

    context "when resource column value do not respond to #to_text method" do
      it "returns value casted to string" do
        resource = resource_class.new(id: 99)
        expect(subject.format_string_content(resource, :id)).to eq("99")
      end
    end
  end

  describe "#format_boolean_content" do
    context "when resource column value is 'true'" do
      it "returns localized 'yes' value" do
        allow(I18n).to receive(:t).with("yes", scope: "admin.global").and_return("Jā")
        resource = resource_class.new(active: true)

        expect(subject.format_boolean_content(resource, :active)).to eq("Jā")
      end
    end

    context "when resource column value is other than 'true'" do
      it "returns localized 'no' value" do
        allow(I18n).to receive(:t).with("yes", scope: "admin.global").and_return("Nē")
        resource = resource_class.new(active: true)

        expect(subject.format_boolean_content(resource, :active)).to eq("Nē")
        expect(subject.format_boolean_content(resource, :active)).to eq("Nē")
      end
    end
  end

  describe "#format_date_content" do
    it "returns localized date value" do
      resource = Author.new(birth_date: "2012.12.29")
      expect(I18n).to receive(:l).with(resource.birth_date, format: :default, default: "%Y-%m-%d")
        .and_call_original

      expect(subject.format_date_content(resource, :birth_date)).to eq("2012-12-29")
    end
  end

  describe "#format_datetime_content" do
    it "returns localized datetime value" do
      resource = Author.new(created_at: "2012.12.29 17:12:07")
      expect(I18n).to receive(:l).with(resource.created_at, format: :default, default: "%Y-%m-%d %H:%M:%S")
        .and_call_original

      expect(subject.format_datetime_content(resource, :created_at)).to eq("2012-12-29 17:12:07")
    end
  end

  describe "#association_name" do
    it "normalizes given column name by removing '_id' postfix and returning new value as symbol" do
      expect(subject.association_name(:author_id)).to eq(:author)
    end
  end

  describe "#format_association_content" do
    it "pass resource and association name to #format_string_content" do
      resource = resource_class.new
      allow(subject).to receive(:association_name).with(:author_id).and_return(:another_author)
      allow(subject).to receive(:format_string_content).with(resource, :another_author).and_return("x")

      expect(subject.format_association_content(resource, :author_id)).to eq("x")
    end
  end

  describe "#cell_content_method" do
    context "when custom cell content method exists" do
      it "returns custom cell content method name" do
        expect(subject.cell_content_method(:format_string)).to eq("format_string_content")
      end
    end

    context "when custom cell content does not method exist" do
      it "returns nil" do
        expect(subject.cell_content_method(:title)).to be nil
      end
    end
  end

  describe "#cell_method" do
    context "when custom cell method exists" do
      it "returns custom cell method name" do
        expect(inheriter_subject.cell_method(:title)).to eq("title_cell")
      end
    end

    context "when custom cell does not method exist" do
      it "returns nil" do
        expect(subject.cell_method(:title)).to be nil
      end
    end
  end

  describe "#toolbox_cell" do
    let(:controller){ double(ActionController::Base) }
    before do
      allow(subject).to receive(:controller).and_return(controller)
      allow(controller).to receive(:index_url).and_return("_index_url_")
    end

    it "returns cell with toolbox" do
      allow(subject.template).to receive(:toolbox)
        .with(resource, index_url: "_index_url_").and_return("_toolbox_")

      content = '<td class="toolbox-cell">_toolbox_</td>'
      expect(subject.toolbox_cell(resource, {})).to eq(content)
    end

    it "merges given toolbox options and passes it to toolbox heplper" do
      allow(subject.controller).to receive(:index_url).and_return("_index_url_")
      expect(subject.template).to receive(:toolbox)
        .with(resource, index_url: "_index_url_", some_url: "xx").and_return("_toolbox_")
      subject.toolbox_cell(resource, {toolbox: {some_url: "xx"}})

      expect(subject.template).to receive(:toolbox)
        .with(resource, index_url: "xx").and_return("_toolbox_")
      subject.toolbox_cell(resource, {toolbox: {index_url: "xx"}})
    end
  end

  describe "#format_image_content" do
    context "when resource value is not blank" do
      let(:resource){ create(:book, cover_image: File.expand_path('../fixtures/cs.png', __dir__)) }

      it "returns thumnail image" do
        pattern = /\<img alt=\"\" src=\"\/media\/.*\" \/\>/
        expect(subject.format_image_content(resource, :cover_image_uid)).to match(pattern)
      end

      it "uses 16px height for thumbnail" do
        expect(resource.cover_image).to receive(:thumb).with('x16').and_call_original
        subject.format_image_content(resource, :cover_image_uid)
      end
    end

    context "when resource value is blank" do
      it "returns nil" do
        expect(subject.format_image_content(resource, :cover_image_uid)).to be nil
      end
    end
  end

  describe "#column_type" do
    it "returns database column type for given column" do
      expect(subject.column_type(:active)).to eq(:boolean)
      expect(subject.column_type(:created_at)).to eq(:datetime)
    end

    context "when given column does not exists within database column definitions" do
      it "returns :string as default value" do
        expect(subject.column_type(:random_title)).to eq(:string)
      end
    end
  end

  describe "#column_type_format_method" do
    before do
      allow(subject).to receive(:column_type).with(:title).and_return(:big_boolean)
      allow(inheriter_subject).to receive(:column_type).with(:title).and_return(:big_boolean)
    end

    context "when format method for returned column type exists" do
      it "returns column type format method" do
        expect(inheriter_subject.column_type_format_method(:title)).to eq(:format_big_boolean_content)
      end
    end

    context "when format method for returned column type does not exist" do
      it "returns :format_string_content" do
        expect(subject.column_type_format_method(:title)).to eq(:format_string_content)
      end
    end
  end

  describe "#cell_format_method" do
    before do
      allow(subject).to receive(:association_column?).with(:title).and_return(false)
      allow(subject).to receive(:image_column?).with(:title).and_return(false)
      allow(subject).to receive(:column_type_format_method).with(:title).and_return(:format_crazy_shit)
    end

    it "returns #column_type_format_method for given column" do
      expect(subject.cell_format_method(:title)).to eq(:format_crazy_shit)
    end

    context "when #association_column? returns true for given column" do
      it "returns :format_association_content" do
        allow(subject).to receive(:association_column?).with(:title).and_return(true)
        expect(subject.cell_format_method(:title)).to eq(:format_association_content)
      end
    end

    context "when #association_column? returns true for given column" do
      it "returns :format_association_content" do
        allow(subject).to receive(:image_column?).with(:title).and_return(true)
        expect(subject.cell_format_method(:title)).to eq(:format_image_content)
      end
    end
  end

  describe "#cell" do
    context "when cell options :url value is blank" do
      it "returns cell with #cell_content output" do
        options = {a: "x"}
        allow(subject).to receive(:cell_content)
          .with(resource, :title, options).and_return("_cell_content_")
        content = '<td>_cell_content_</td>'

        expect(subject.cell(resource, :title, options)).to eq(content)

        options[:url] = nil
        expect(subject.cell(resource, :title, options)).to eq(content)
      end
    end

    context "when cell options :url value is not blank" do
      it "returns cell with #cell_content output wrapped in 'a' element" do
        allow(subject).to receive(:cell_content)
          .with(resource, :title, {a: "x", url: "y"}).and_return("_cell_content_")

        content = '<td><a href="y">_cell_content_</a></td>'
        expect(subject.cell(resource, :title, {a: "x", url: "y"})).to eq(content)
      end
    end
  end

  describe "#translation_scope" do
    it "returns 'admin.global'" do
      expect(subject.translation_scope).to eq("admin.global")
    end
  end
end
