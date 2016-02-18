require "rails_helper"

describe Releaf::ResourceTableFields do
  subject{ described_class.new(Book) }

  describe "#excluded_attributes" do
    it "returns attributes to exclude from table alongside parent method list" do
      allow(subject).to receive(:table_excluded_attributes).and_return(%w(xxx yyy))
      expect(subject.excluded_attributes).to include("id", "created_at", "xxx", "yyy")
    end
  end

  describe "#table_excluded_attributes" do
    it "returns array with all base and localized attributes matching *_html and *_uid pattern" do
      allow(subject).to receive(:localized_attributes).and_return(["color", "body_html", "some_uid"])
      allow(subject).to receive(:base_attributes).and_return(["image_uid", "title", "price", "description_html"])
      expect(subject.table_excluded_attributes).to eq(%w(image_uid description_html body_html some_uid))
    end
  end
end
