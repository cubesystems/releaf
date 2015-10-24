require "rails_helper"

describe Releaf::Core::ResourceTableFields do
  subject{ described_class.new(Book) }

  describe "#excluded_attributes" do
    it "returns attributes to exclude from table alongside parent method list" do
      allow(subject).to receive(:table_excluded_attributes).and_return(%w(xxx yyy))
      expect(subject.excluded_attributes).to include("id", "created_at", "xxx", "yyy")
    end
  end

  describe "#table_excluded_attributes" do
    it "returns array with attributes matching *_html pattern" do
      expect(subject.table_excluded_attributes).to eq(%w(summary_html))
    end
  end
end
