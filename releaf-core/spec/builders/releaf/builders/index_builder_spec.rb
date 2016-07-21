require "rails_helper"

describe Releaf::Builders::IndexBuilder, type: :class do
  class TranslationsIndexBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    delegate :resource_class, :table_options, to: :controller

    def controller
      @controller ||= Admin::BooksController.new
    end
  end

  let(:template){ TranslationsIndexBuilderTestHelper.new }
  let(:subject){ described_class.new(template) }
  let(:collection){ Book.page(1).per_page(2) }

  before do
    allow(subject).to receive(:controller_name).and_return("_controller_name_")
    allow(subject).to receive(:collection).and_return(collection)
  end

  it "includes Releaf::Builders::View" do
    expect(described_class.ancestors).to include(Releaf::Builders::View)
  end

  it "includes Releaf::Builders::Collection" do
    expect(described_class.ancestors).to include(Releaf::Builders::Collection)
  end

  describe "#dialog?" do
    it "returns false" do
      expect(subject.dialog?).to be false
    end
  end

  describe "#search_block" do
    before do
      allow(subject).to receive(:text_search_block).and_return("aa")
      allow(subject).to receive(:extra_search_block).and_return("bb")
      allow(subject).to receive(:search_form_attributes).and_return(a: "xx")
    end

    it "returns search from with attributes and text/extra search blocks" do
      expect(subject.search_block).to eq('<form a="xx">aabb</form>')
    end

    context "when no text blocks available" do
      it "returns nil" do
        allow(subject).to receive(:text_search_block).and_return(nil)
        allow(subject).to receive(:extra_search_block).and_return(nil)
        expect(subject.search_block).to be nil
      end
    end
  end

  describe "#search_form_attributes" do
    before do
      allow(subject).to receive(:text_search_available?).and_return(true)
      allow(subject).to receive(:extra_search_available?).and_return(true)
      allow(subject.template).to receive(:url_for).with(controller: "_controller_name_", action: "index").and_return("x")
    end

    it "returns url and css classes for search form" do
      classes = ["search", "has-text-search", "has-extra-search"]
      expect(subject.search_form_attributes).to eq(class: classes, action: "x")
    end

    context "when text search is not available" do
      it "does not add text search class" do
        allow(subject).to receive(:text_search_available?).and_return(false)
        expect(subject.search_form_attributes[:class]).to_not include("has-text-search")
      end
    end

    context "when extra search is not available" do
      it "does not add extra search class" do
        allow(subject).to receive(:extra_search_available?).and_return(false)
        expect(subject.search_form_attributes[:class]).to_not include("has-extra-search")
      end
    end
  end

  describe "#header_extras" do
    before do
      allow(subject).to receive(:search_block).and_return("x")
    end

    context "when search feature is enabled" do
      it "returns search block" do
        allow(subject).to receive(:feature_available?).with(:search).and_return(true)
        expect(subject.header_extras).to eq("x")
      end
    end

    context "when search feature is disabled" do
      it "returns nil" do
        allow(subject).to receive(:feature_available?).with(:search).and_return(false)
        expect(subject.header_extras).to be nil
      end
    end
  end

  describe "#extra_search_available?" do
    context "when extra search block is present" do
      it "returns true" do
        allow(subject).to receive(:extra_search_block).and_return("x")
        expect(subject.extra_search_available?).to be true
      end
    end

    context "when extra search block is nil" do
      it "returns false" do
        allow(subject).to receive(:extra_search_block).and_return(nil)
        expect(subject.extra_search_available?).to be false
      end
    end
  end

  describe "#text_search_available?", focus: true do
    context "when template variable `searchable_fields` is present" do
      it "returns true" do
        allow( template.controller ).to receive(:searchable_fields).and_return([:a])
        expect(subject.text_search_available?).to be true
      end
    end

    context "when template variable `searchable_fields` is blank" do
      it "returns false" do
        allow( template.controller ).to receive(:searchable_fields).and_return([])
        expect(subject.text_search_available?).to be false
      end
    end
  end

  describe "#text_search_block" do
    before do
      allow(subject).to receive(:text_search_content).and_return("x")
    end

    context "when text search is available" do
      it "returns true" do
        allow(subject).to receive(:text_search_available?).and_return(true)
        expect(subject.text_search_block).to eq('<div class="text-search">x</div>')
      end
    end

    context "when text search is not available" do
      it "returns false" do
        allow(subject).to receive(:text_search_available?).and_return(false)
        expect(subject.text_search_block).to be nil
      end
    end
  end

  describe "#text_search_content" do

    it "returns text search field and button" do
      allow(subject).to receive(:t).with('Search').and_return("sss")
      allow(subject).to receive(:params).and_return(search: "xxx")
      allow(subject).to receive(:button)
        .with(nil, "search", type: "submit", title: 'sss')
        .and_return("<search_button />".html_safe)
      expect(subject).to receive(:search_field).with("search").and_call_original
      expect(subject.text_search_content).to match_html(%Q[
        <div class="search-field" data-name="search">
          <input name="search" type="search" class="text" value="xxx" autofocus="autofocus"></input>
          <search_button />
        </div>
      ])
    end

  end

  describe "#search_field" do
    it "returns the given block in a search field wrapper" do
      expect(subject.search_field("foo") { '<block_html>'.html_safe }).to match_html(%Q[
        <div class="search-field" data-name="foo">
          <block_html>
        </div>
      ])
    end
  end

  describe "#extra_search_content" do
    it "returns nil(available for override)" do
      expect(subject.extra_search_content).to be nil
    end
  end

  describe "#extra_search_button" do
    it "returns extra search button" do
      allow(subject).to receive(:t).with('Search').and_return("sss")
      allow(subject).to receive(:t).with('Filter').and_return("fff")
      allow(subject).to receive(:button)
        .with("fff", "search", type: "submit", title: 'sss')
        .and_return("xx")
      expect(subject.extra_search_button).to eq("xx")
    end
  end

  describe "#extra_search_block" do
    before do
      allow(subject).to receive(:extra_search_button).and_return("btn")
      allow(subject).to receive(:extra_search_content).and_return("xx")
    end

    it "returns extra search block" do
      expect(subject.extra_search_block).to eq('<div class="extras">xxbtn</div>')
    end

    it "caches extra search content" do
      allow(subject).to receive(:extra_search_content).and_return("xx").once
      subject.extra_search_block
      subject.extra_search_block
    end

    context "when extra search content is not present" do
      it "returns nil" do
        allow(subject).to receive(:extra_search_content).and_return(nil)
        expect(subject.extra_search_block).to be nil
      end
    end
  end

  describe "#section_header_text" do
    it "returns section header text" do
      allow(subject).to receive(:t).with('All resources').and_return("all")
      expect(subject.section_header_text).to eq("all")
    end
  end

  describe "#section_header_extras" do
    it "returns true" do
      allow(subject).to receive(:t)
        .with("Resources found", count: 0, default: "%{count} resources found", create_plurals: true)
        .and_return("sss")
      expect(subject.section_header_extras).to eq('<span class="extras totals only-text">sss</span>')
    end

    context "when collection does not respond to total_entries" do
      it "returns nil" do
        allow(subject).to receive(:collection).and_return(Book.all)
        expect(subject.section_header_extras).to be nil
      end
    end
  end

  describe "#footer_blocks" do
    before do
      allow(subject).to receive(:footer_primary_block).and_return("a")
      allow(subject).to receive(:pagination_block).and_return("b")
      allow(subject).to receive(:footer_secondary_block).and_return("c")
      allow(subject).to receive(:pagination?).and_return(true)
    end

    it "returns array with footer primary, pagination and secondary blocks" do
      expect(subject.footer_blocks).to eq(["a", "b", "c"])
    end

    context "when pagination is not available" do
      it "does not include pagination block within returned array" do
        allow(subject).to receive(:pagination?).and_return(false)
        expect(subject.footer_blocks).to eq(["a", "c"])
      end
    end
  end

  describe "#footer_primary_tools" do
    before do
      allow(subject).to receive(:resource_creation_button).and_return("a")
      allow(subject).to receive(:feature_available?).with(:create).and_return(true)
    end

    it "returns array with resource creation button" do
      expect(subject.footer_primary_tools).to eq(["a"])
    end

    context "when creation feature is not available" do
      it "returns empty array" do
        allow(subject).to receive(:feature_available?).with(:create).and_return(false)
        expect(subject.footer_primary_tools).to eq([])
      end
    end
  end

  describe "#pagination?" do
    context "when collection responds to `page` method" do
      it "returns true" do
        expect(subject.pagination?).to be true
      end
    end

    context "when collection does not respond to `page` method" do
      it "returns false" do
        allow(subject).to receive(:collection).and_return(Book.all)
        expect(subject.pagination?).to be true
      end
    end
  end

  describe "#pagination_builder_class" do
    it "returns a builder class" do
      expect(subject.pagination_builder_class).to be_a Class
    end
  end

  describe "#pagination_block" do

    before do
      allow(subject).to receive(:params).and_return(page: "2")
    end

    it "constructs a new pagination builder and returns its output" do
      builder_args = [ template, { collection: collection, params: { page: "2" } } ]
      builder = Releaf::Builders::PaginationBuilder.new( *builder_args )

      expect(builder.class).to receive(:new).with( *builder_args ).and_return( builder )
      expect(builder).to receive(:output).and_return("xx")

      expect(subject.pagination_block).to eq("xx")
    end

    it "uses pagination builder class" do
      dummy = double
      allow(dummy).to receive(:new).and_return(dummy)
      allow(dummy).to receive(:output).and_return(:ok)
      expect(subject).to receive(:pagination_builder_class).and_return(dummy)
      expect( subject.pagination_block).to eq :ok
    end
  end

  describe "#resource_creation_button" do
    it "returns resource creation button" do
      allow(subject.template).to receive(:url_for).with(controller: "_controller_name_", action: "new").and_return("x")
      allow(subject).to receive(:t).with('Create new resource').and_return("sss")
      allow(subject).to receive(:button)
        .with("sss", "plus", class: "primary", href: "x")
        .and_return("btn")
      expect(subject.resource_creation_button).to eq("btn")
    end
  end

  describe "#section_body" do
    it "returns collection table" do
      allow(template).to receive(:releaf_table)
        .with(collection, Book, builder: Admin::Books::TableBuilder, toolbox: true)
        .and_return("xx")
      expect(subject.section_body).to eq('<div class="body">xx</div>')
    end
  end

  describe "#table_options" do
    it "returns table options" do
      allow(subject).to receive(:builder_class).with(:table).and_return("CustomTableBuilderClassHere")
      allow(subject).to receive(:feature_available?).with(:toolbox).and_return("boolean_value_here")

      options = {
        builder: "CustomTableBuilderClassHere",
        toolbox: "boolean_value_here"
      }
      expect(subject.table_options).to eq(options)
    end
  end
end
