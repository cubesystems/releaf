require "rails_helper"

describe Releaf::I18nDatabase::Translations::EditBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base
    def protect_against_forgery?; end
  end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::I18nDatabase::Translation }
  let(:subject){ described_class.new(template) }

  describe "#section" do
    it "returns section blocks wrapped within edit form" do
      allow(subject).to receive(:action_url).with(:update).and_return("update_url")
      allow(subject).to receive(:section_blocks).and_return(["a", "b"])
      result = '<section><form action="update_url" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" />ab</form></section>'
      expect(subject.section).to eq(result)
    end
  end

  describe "#section_body" do
    it "returns section body with form fields partial" do
      allow(subject).to receive(:render).with(partial: "form_fields", locals: {builder: subject}).and_return("xxx")
      expect(subject.section_body).to eq('<div class="body">xxx</div>')
    end
  end

  describe "#import?" do
    it "returns template `import` value" do
      allow(subject).to receive(:template_variable).with("import").and_return("x")
      expect(subject.import?).to eq("x")
    end
  end

  describe "#save_button" do
    it "returns localized value for given resource and column(locale)" do
      allow(subject).to receive(:save_button_text).and_return("sv_txt")
      allow(subject).to receive(:button).with("sv_txt", "check", class: "primary", data: { type: 'ok' }, type: "submit").and_return("save_btn")
      expect(subject.save_button).to eq("save_btn")
    end
  end

  describe "#save_button_text" do
    context "when within import view" do
      it "returns translated `Import` text" do
        allow(subject).to receive(:t).with("Import").and_return("_import_")
        allow(subject).to receive(:import?).and_return(true)
        expect(subject.save_button_text).to eq("_import_")
      end
    end

    context "when not within import view" do
      it "returns translated `Save` text" do
        allow(subject).to receive(:t).with("Save").and_return("_save_")
        allow(subject).to receive(:import?).and_return(false)
        expect(subject.save_button_text).to eq("_save_")
      end
    end
  end

  describe "#footer_secondary_tools" do
    before do
      allow(subject).to receive(:back_to_index_button).and_return("indx_btn")
      allow(subject).to receive(:export_button).and_return("xprt_btn")
    end

    it "returns array with back and export links" do
      allow(subject).to receive(:import?).and_return(false)
      expect(subject.footer_secondary_tools).to eq(["indx_btn", "xprt_btn"])
    end

    context "when within import view" do
      it "does not incliude export button" do
        allow(subject).to receive(:import?).and_return(true)
        expect(subject.footer_secondary_tools).to eq(["indx_btn"])
      end
    end
  end

  describe "#back_to_index_button" do
    it "returns localized value for given resource and column(locale)" do
      allow(subject).to receive(:t).with("Back to list").and_return("back")
      allow(subject).to receive(:action_url).with(:index).and_return("index_path")
      allow(subject).to receive(:button).with("back", "caret-left", class: "secondary", href: "index_path").and_return("index_btn")
      expect(subject.back_to_index_button).to eq("index_btn")
    end
  end

  describe "#section_header" do
    it "returns nil" do
      expect(subject.section_header).to be nil
    end
  end
end
