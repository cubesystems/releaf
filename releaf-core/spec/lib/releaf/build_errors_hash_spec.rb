require 'rails_helper'

describe Releaf::BuildErrorsHash do
  let(:resource) { Book.new }
  let(:error){ ActiveModel::ErrorMessage.new("blank value", :blank) }

  subject do
    described_class.new(resource: resource, field_name_prefix: :resource)
  end

  describe "#call" do
    it "returns hash with merged errors" do
      allow(subject).to receive(:errors).and_return([
        {
          field_name: "name",
          message: "error blank",
          error_code: :blank,
        },
        {
          field_name: "name",
          message: "invalid format",
          error_code: :invalid_format,
        },
        {
          field_name: "surname",
          message: "error blank",
          error_code: :blank,
        },
      ])
      expect(subject.call).to eq(
        "name" => [{message: "error blank", error_code: :blank}, {message: "invalid format", error_code: :invalid_format}],
        "surname" => [{message: "error blank", error_code: :blank}]
      )
    end
  end

  describe "#errors" do
    it "returns flattened errors array" do
      allow(resource).to receive(:errors).and_return(name: "er1", surname: "er2", role: "er3")
      allow(subject).to receive(:format_error).with(:name, "er1").and_return("error1")
      allow(subject).to receive(:format_error).with(:surname, "er2").and_return("error2")
      allow(subject).to receive(:format_error).with(:role, "er3").and_return(["error3", "error4"])
      expect(subject.errors).to eq(["error1", "error2", "error3", "error4"])
    end
  end

  describe "#format_error" do
    before do
      allow(subject).to receive(:attribute_error).with(:name, "er1").and_return("error1")
      allow(subject).to receive(:nested_attribute_errors).with(:name).and_return(["error1", "error2"])
    end

    context "when resource attribute given" do
      it "returns attribute error" do
        allow(subject).to receive(:resource_attribute?).and_return(true)
        expect(subject.format_error(:name, "er1")).to eq("error1")
      end
    end

    context "when nested attribute given" do
      it "returns nested attribute errors" do
        allow(subject).to receive(:resource_attribute?).and_return(false)
        expect(subject.format_error(:name, "er1")).to eq(["error1", "error2"])
      end
    end
  end

  describe "#attribute_error" do
    it "returns attribute error hash" do
      allow(subject).to receive(:field_name).with(:name).and_return("xxx_name")
      expect(subject.format_error(:name, error)).to eq(field_name: "xxx_name", error_code: :blank, message: "blank value")
    end
  end

  describe "#single_association?" do
    context "for :belongs_to association" do
      it "returns true" do
        expect( subject.single_association?('author') ).to be true
      end
    end

    context "for :has_many association" do
      it "returns false" do
        expect( subject.single_association?('chapters') ).to be false
      end
    end

    context "for :has_one association" do
      it "returns true" do
        allow(subject).to receive(:association_type).with('author').and_return(:has_one)
        expect( subject.single_association?('author') ).to be true
      end
    end
  end

  describe "#association" do
    it "returns active record reflection of association" do
      expect( subject.send(:association, 'author') ).to eq Book.reflect_on_association(:author)
    end
  end

  describe "#association_type" do
    it "returns active record reflection macro" do
      expect( subject.association_type('author') ).to eq :belongs_to
    end
  end

  describe "#resource_attribute?" do
    context "when attribute name contains dot" do
      it "returns false" do
        expect( subject.resource_attribute?('test.attribute') ).to be false
      end
    end

    context "when attribute name doesn't contain dot" do
      it "returns true" do
        expect( subject.resource_attribute?('test') ).to be true
      end
    end
  end

  describe "#field_name" do
    context "when error is on base" do
      it "returns resource field_id" do
        expect( subject.field_name('base')).to eq 'resource'
      end
    end

    context "when attribute is association" do
      it "returns field_id for associations foreign key" do
        expect( subject.field_name('author')).to eq 'resource[author_id]'
      end
    end

    context "when attribute is not association" do
      it "returns field_id for field" do
        expect( subject.field_name('title')).to eq 'resource[title]'
      end
    end
  end
end
