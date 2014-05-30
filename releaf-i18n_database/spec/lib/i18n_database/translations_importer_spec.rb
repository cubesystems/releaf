require "spec_helper"

describe Releaf::I18nDatabase::TranslationsImporter do
  describe "#initialize" do
    context "when unsupported extension given" do
      it "raises Releaf::TranslationsImporter::UnsupportedFileFormatError" do
        expect{described_class.new("xx", "xx")}.to raise_error(described_class::UnsupportedFileFormatError)
      end
    end

    context "when error raised from Roo" do
      it "raises it" do
        expect{described_class.new("xx", "xls")}.to raise_error(IOError)
      end
    end
  end
end
