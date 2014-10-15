require "spec_helper"

describe Releaf::TableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Book }
  let(:collection){ Book.all }
  let(:options){ {toolbox: false} }
  let(:subject){ described_class.new(collection, resource_class, template, options) }

  it "includes Releaf::Builder" do
    expect(Releaf::TableBuilder.ancestors).to include(Releaf::Builder)
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

    it "assigns build_columns output to columns" do
      subject = described_class.allocate
      allow(subject).to receive(:build_columns).and_return("x")
      subject.send(:initialize, collection, resource_class, template, options)
      expect(subject.columns).to eq("x")
    end
  end

  describe "#column_names" do
    it "returns column names for resource_class" do
      allow(subject).to receive(:resource_class_attributes).with(subject.resource_class).and_return(["a", "b"])
      expect(subject.column_names).to eq(["a", "b"])
    end
  end

  describe "#build_columns" do
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
      expect(subject.build_columns).to eq(columns)
    end

    it "preserves order as in #column_names" do
      expect(subject.build_columns.keys).to eq([:price, :title, :author_id])
    end

    context "when options[:toolbox] value is 'true'" do
      let(:options){ {toolbox: true} }
      it "adds toolbox as first column" do
        expect(subject.build_columns.keys.first).to eq(:toolbox)
      end

      it "uses #toolbox_cell for toolbox cell rendering" do
        expect(subject.build_columns[:toolbox]).to eq(cell_method: "toolbox_cell")
      end
    end
  end

  describe "#table" do
    before do
      allow(subject).to receive(:empty_body).and_return("empty")
    end

    it "returns table with #empty_body content" do
      allow(subject).to receive(:table_attributes).and_return(class: "a", data: {some: "b"})
      content = '<table class="a" data-some="b">empty</table>'
      expect(subject.table).to eq(content)
    end

    context "when collection is not empty" do
      it "returns table with #header and #body" do
        create(:book)
        content = '<table class="table">header_contentbody_content</table>'
        allow(subject).to receive(:head).and_return("header_content")
        allow(subject).to receive(:body).and_return("body_content")

        expect(subject.table).to eq(content)
      end
    end

    context "when collection is empty" do
      it "returns table with #empty_body content" do
        content = '<table class="table">empty</table>'
        expect(subject.table).to eq(content)
      end
    end
  end

  describe "#table_attributes" do
    it "returns hash with table class" do
      expect(subject.table_attributes).to eq(class: "table")
    end
  end
end
