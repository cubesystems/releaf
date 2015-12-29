require "rails_helper"

describe Releaf::I18nDatabase::Translations::IndexBuilder, type: :class do
  class IndexBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    delegate :resource_class, :table_options, to: :controller

    def protect_against_forgery?; end

    def controller
      @controller ||= begin
                        c = Releaf::I18nDatabase::TranslationsController.new
                        c.setup
                        c
                      end
    end
  end
  let(:template){ IndexBuilderTestHelper.new }
  let(:resource_class){ Releaf::I18nDatabase::Translation }
  let(:subject){ described_class.new(template) }

  describe "#text_search_content" do
    it "adds blank translation checbox to text search" do
      allow(subject).to receive(:t).and_return("search")
      allow(subject).to receive(:params).and_return(search: "xx")
      allow(subject).to receive(:button).and_return("btn")
      allow(subject).to receive(:search_only_blank_ui).and_return("_blank_ui_")
      expect(subject.text_search_content).to start_with("_blank_ui_")
    end
  end

  describe "#search_only_blank_ui" do
    before do
      allow(subject).to receive(:t).with("Only blank").and_return("trnls")
    end

    it "returns only blank translation search ui" do
      allow(subject).to receive(:params).and_return(search: "xx")
      expect(subject.search_only_blank_ui).to match_html(%Q[
          <div class="search-field" data-name="only-blank">
              <input type="checkbox" name="only_blank" id="only_blank" value="true" />
              <label for="only_blank">trnls</label>
          </div>
      ])
    end

    it "reflects `only_blank` params to checkbox state" do
      allow(subject).to receive(:params).and_return(only_blank: "1", search: true)
      expect(subject.search_only_blank_ui).to match_html(%Q[
          <div class="search-field" data-name="only-blank">
              <input type="checkbox" name="only_blank" id="only_blank" value="true" checked="checked" />
              <label for=\"only_blank\">trnls</label>
          </div>
      ])
    end
  end

  describe "#footer_primary_tools" do
    it "returns array with edit button" do
      allow(subject).to receive(:edit_button).and_return("btn")
      expect(subject.footer_primary_tools).to eq(["btn"])
    end
  end

  describe "#footer_secondary_tools" do
    it "returns array with edit button" do
      allow(subject).to receive(:export_button).and_return("a")
      allow(subject).to receive(:import_button).and_return("b")
      allow(subject).to receive(:import_form).and_return("c")
      expect(subject.footer_secondary_tools).to eq(["a", "b", "c"])
    end
  end

  describe "#import_form" do
    it "returns import form" do
      allow(subject).to receive(:url_for).with(action: 'import').and_return("import_url")
      result = "<form class=\"import\" enctype=\"multipart/form-data\" action=\"import_url\" accept-charset=\"UTF-8\" method=\"post\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /><input type=\"file\" name=\"import_file\" id=\"import_file\" /></form>"
      expect(subject.import_form).to eq(result)
    end
  end

  describe "#edit_button" do
    it "return edit button" do
      allow(subject).to receive(:t).with("Edit").and_return("edt")
      allow(subject).to receive(:action_url).with(:edit).and_return("edt_url")
      allow(subject).to receive(:button).with("edt", "edit", class: "primary", href: "edt_url").and_return("edt_btn")
      expect(subject.edit_button).to eq("edt_btn")
    end
  end

  describe "#text_search_available?" do
    it "return true" do
      expect(subject.text_search_available?).to be true
    end
  end
end
