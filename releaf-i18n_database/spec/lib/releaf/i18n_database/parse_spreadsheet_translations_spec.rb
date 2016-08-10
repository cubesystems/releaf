require "rails_helper"

describe Releaf::I18nDatabase::ParseSpreadsheetTranslations do
  let(:translation){ Releaf::I18nDatabase::I18nEntry.new }
  let(:fixture_path){ File.expand_path('../../../fixtures/translations_import.xlsx', __dir__) }
  let(:error_message){ "Don't know how to open file #{fixture_path}" }
  subject{ described_class.new(file_path: fixture_path, extension: "xlsx") }

  describe "#call" do
    it "returns translations" do
      allow(subject).to receive(:translations).and_return("x")
      expect(subject.call).to eq("x")
    end
  end

  describe "#rows" do
    let(:spreadsheet){ Roo::Spreadsheet.open(fixture_path) }

    before do
      allow(subject).to receive(:spreadsheet).and_return(spreadsheet)
    end

    it "returns speadsheet casted to array" do
      allow(spreadsheet).to receive(:to_a).and_return([1, 2])
      expect(subject.rows).to eq([1, 2])
    end

    it "caches casted array" do
      expect(spreadsheet).to receive(:to_a).and_return([1, 2]).once
      subject.rows
      subject.rows
    end
  end

  describe "#data_rows" do
    it "returns all rows except first and one with empty first value (key)" do
      allow(subject).to receive(:rows).and_return([[1, 2, 3], [:a, 2, 3], [nil, 2, 4], ["", 4, 1], [6, 2, ""]])
      expect(subject.data_rows).to eq([[:a, 2, 3], [6, 2, ""]])
    end
  end

  describe "#locales" do
    it "returns all non blank values from first row" do
      allow(subject).to receive(:rows).and_return([["lv", "", "de", nil, "en"], [:a, 2, 3], [6, 2, ""]])
      expect(subject.locales).to eq(["lv", "de", "en"])
    end

    it "caches resolved values" do
      expect(subject).to receive(:rows).and_return([["lv", "", "de", nil, "en"], [:a, 2, 3], [6, 2, ""]]).once
      subject.locales
      subject.locales
    end
  end

  describe "#spreadsheet" do
    it "returns Roo spreadsheet instance" do
      allow(Roo::Spreadsheet).to receive(:open).with(fixture_path, extension: "xlsx", file_warning: :ignore).and_return("instance")
      expect(subject.spreadsheet).to eq("instance")
    end


    context "when opening the file raises an unsupported content error" do
      it "raises Releaf::TranslationsImporter::UnsupportedFileFormatError" do
        error = ArgumentError.new("error message")
        allow(Roo::Spreadsheet).to receive(:open).and_raise( error )
        expect(subject).to receive(:file_format_error?).with( "ArgumentError", "error message").and_return true
        expect{ subject.spreadsheet }.to raise_error(described_class::UnsupportedFileFormatError)
      end
    end

    context "when opening the file raises any other error" do
      it "raises Releaf::TranslationsImporter::UnsupportedFileFormatError" do
        error = ArgumentError.new("error message")
        allow(Roo::Spreadsheet).to receive(:open).and_raise( error )
        expect(subject).to receive(:file_format_error?).with( "ArgumentError", "error message").and_return false
        expect{ subject.spreadsheet }.to raise_error( error )
      end
    end

  end

  describe "#file_format_error?" do

    context "when given error is an ArgumentError" do
      context "when the message contains 'Don't know how to open file'" do
        it "returns true" do
          expect(subject.file_format_error?("ArgumentError", error_message)).to be true
        end
      end
      context "when the message is different" do
        it "returns false" do
          expect(subject.file_format_error?("ArgumentError", "error message")).to be false
        end
      end
    end

    context "when the error is a Zip::ZipError" do
      it "returns true" do
        expect(subject.file_format_error?("Zip::ZipError", "error message")).to be true
      end
    end

    context "when the error is a Ole::Storage::FormatError" do
      it "returns true" do
        expect(subject.file_format_error?("Ole::Storage::FormatError", "error message")).to be true
      end
    end


  end


  describe "#translations" do
    it "returns array of processed `Releaf::I18nDatabase::Translation` instances" do
      allow(subject).to receive(:data_rows).and_return([[1, 2, 3], [:a, nil, 3], [6, 2, ""]])
      allow(subject).to receive(:translation_instance).with(1, ["2", "3"]).and_return("t1")
      allow(subject).to receive(:translation_instance).with(:a, ["", "3"]).and_return("t2")
      allow(subject).to receive(:translation_instance).with(6, ["2", ""]).and_return("t3")
      expect(subject.translations).to eq(["t1", "t2", "t3"])
    end
  end

  describe "#translation_instance" do
    it "returns first or initialized translation for given key and given localizations built" do
      where_scope = Releaf::I18nDatabase::I18nEntry.where(key: ["sommmmquery"])
      allow(Releaf::I18nDatabase::I18nEntry).to receive(:where).with(key: "as.ld").and_return(where_scope)
      allow(where_scope).to receive(:first_or_initialize).and_return(translation)

      expect(subject).to receive(:maintain_translation_locales).with(translation, ["x", "y"])
      expect(subject.translation_instance("as.ld", ["x", "y"])).to eq(translation)
    end
  end

  describe "#maintain_translation_locales" do
    before do
      allow(subject).to receive(:locales).and_return(["en", "de", "ge", "lv"])
      translation.i18n_entry_translation.build(locale: "de", text: "po")
      translation.i18n_entry_translation.build(locale: "ge", text: "x")
    end

    it "builds translation data for all missing locales" do
      expect{ subject.maintain_translation_locales(translation, ["ent", "det", "get", "lvt"]) }
        .to change{ translation.i18n_entry_translation.map{|td| td.locale } }.from(["de", "ge"]).to(["de", "ge", "en", "lv"])
    end

    it "overwrites existing translation data localizations only if new localizations is not empty" do
      expect{ subject.maintain_translation_locales(translation, ["ent", "", "get", "lvt"]) }
        .to change{ translation.i18n_entry_translation.map{|td| [td.locale, td.text] } }.to([["de", "po"], ["ge", "get"], ["en", "ent"], ["lv", "lvt"]])
    end
  end
end
