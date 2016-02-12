require "rails_helper"

describe Releaf::Builders::Utilities::ResolveAttributeFieldMethodName do
  let(:object){ Book.new }
  subject{ described_class.new(object: object, attribute_name: "title") }

  describe "#call" do
    before do
      allow(subject).to receive(:field_type).and_return("color_picker")
    end

    it "returns resolved field name method" do
      expect(subject.call).to eq("releaf_color_picker_field")
    end


    context "when localized attribute" do
      it "adds i18n part to returned field name method" do
        allow(subject).to receive(:localized_attribute?).and_return(true)
        expect(subject.call).to eq("releaf_color_picker_i18n_field")
      end
    end
  end

  describe "#field_type" do
    before do
      allow(subject).to receive(:column_type).and_return("doubleinteger")
    end

    it "returns first positive resolver name" do
      allow(subject).to receive(:column_field_type_resolvers).and_return([:text, :item, :richtext])
      expect(subject).to receive(:text?).and_return(false)
      expect(subject).to receive(:item?).and_return(true)
      expect(subject).to_not receive(:richtext?)

      expect(subject.field_type).to eq(:item)
    end

    context "when no resolvers exists" do
      it "returns column type" do
        allow(subject).to receive(:column_field_type_resolvers).and_return([])
        expect(subject.field_type).to eq("doubleinteger")
      end
    end
  end

  describe "#column_type" do
    let(:column){ Book.columns_hash["id"] }

    before do
      subject.attribute_name = "birth_date"
      allow(subject).to receive(:columns_class).and_return(Author)
      allow(column).to receive(:type).and_return("doubleinteger")
    end

    it "returns column type from columns class" do
      allow(Author.columns_hash).to receive(:[]).with("birth_date").and_return(column)
      expect(subject.column_type).to eq("doubleinteger")
    end

    context "when attribute does not exists within columns hash" do
      it "returns `string` as default type" do
        allow(Author.columns_hash).to receive(:[]).with("birth_date").and_return(nil)
        expect(subject.column_type).to eq(:string)
      end
    end

    it "caches resolved column type" do
      expect(Author.columns_hash).to receive(:[]).with("birth_date").and_return(column).twice
      subject.column_type
      subject.column_type
      subject.column_type
    end
  end

  describe "#columns_class" do
    context "when non localized attribute" do
      it "returns object class" do
        allow(subject).to receive(:localized_attribute?).and_return(false)
        expect(subject.columns_class).to eq(Book)
      end
    end

    context "when localized attribute" do
      it "returns object translations class" do
        allow(subject).to receive(:localized_attribute?).and_return(true)
        expect(subject.columns_class).to eq(Book::Translation)
      end
    end
  end

  describe "#column_field_type_resolvers" do
    it "returns column type resolvers" do
      allow(subject).to receive(:column_type).and_return(:text)
      expect(subject.column_field_type_resolvers).to eq([:link, :richtext, :textarea])

      allow(subject).to receive(:column_type).and_return(:float)
      expect(subject.column_field_type_resolvers).to eq([])
    end
  end

  describe "#localized_attribute?" do
    context "when object translates" do
      context "when given attribute translatable" do
        it "returns true" do
          subject.attribute_name = :description
          expect(subject.localized_attribute?).to be true
        end
      end

      context "when attribute does not translatable" do
        it "returns false" do
          subject.attribute_name = :title
          expect(subject.localized_attribute?).to be false
        end
      end
    end

    context "when object does not translates" do
      it "returns false" do
        subject.object = Releaf::Permissions::User.new
        subject.attribute_name = :password
        expect(subject.localized_attribute?).to be false
      end
    end
  end

  describe "#file?" do
    context "when attribute name ends with `_uid` and object respond to matching file method" do
      it "returns true" do
        subject.attribute_name = "cover_image_uid"
        expect(subject.file?).to be true
      end
    end

    context "when attribute name hasn't *_uid and object respond to matching file method" do
      it "returns false" do
        subject.attribute_name = "genre"
        expect(subject.file?).to be false
      end
    end

    context "when attribute name ends with `_uid` and object does not respond to matching file method" do
      it "returns false" do
        subject.attribute_name = "cover_asdasdd_uid"
        expect(subject.file?).to be false
      end
    end
  end

  describe "#image?" do
    context "when attribute name matches image regexp and attribute is file" do
      it "returns true" do
        allow(subject).to receive(:file?).and_return(true)
        %w(thumbnail image photo picture avatar logo banner icon).each do|prefix|
          subject.attribute_name = "#{prefix}_uid"
          expect(subject.image?).to be true
        end
      end
    end

    context "when attribute name matches image regexp and attribute is not file" do
      it "returns false" do
        allow(subject).to receive(:file?).and_return(false)
        %w(thumbnail image photo picture avatar logo banner icon).each do|prefix|
          subject.attribute_name = "#{prefix}_uid"
          expect(subject.image?).to be false
        end
      end
    end

    context "when attribute name does not match image regexp and attribute is file" do
      it "returns false" do
        allow(subject).to receive(:file?).and_return(true)
        %w(thumcbnail idsfmage pdhoto pictdure avdatar lodgo bdanner idcon).each do|prefix|
          subject.attribute_name = "#{prefix}_uid"
          expect(subject.image?).to be false
        end
      end
    end
  end

  describe "#password?" do
    context "when attribute matches password regexp" do
      it "returns true" do
        %w(some_password password_test password pin).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.password?).to be true
        end
      end
    end

    context "when attribute does not match password regexp" do
      it "returns false" do
        %w(some_pasword pasword not_pin pins).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.password?).to be false
        end
      end
    end
  end

  describe "#email?" do
    context "when attribute matches email regexp" do
      it "returns true" do
        %w(email some_email).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.email?).to be true
        end
      end
    end

    context "when attribute does not match email regexp" do
      it "returns false" do
        %w(email_some mail).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.email?).to be false
        end
      end
    end
  end

  describe "#link?" do
    context "when attribute matches link regexp" do
      it "returns true" do
        %w(some_url some_link link url).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.link?).to be true
        end
      end
    end

    context "when attribute does not match link regexp" do
      it "returns false" do
        %w(urla linka).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.link?).to be false
        end
      end
    end
  end

  describe "#richtext?" do
    context "when attribute matches richtext regexp" do
      it "returns true" do
        %w(some_html html).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.richtext?).to be true
        end
      end
    end

    context "when attribute does not match richtext regexp" do
      it "returns false" do
        %w(htmla ad_htmla).each do|attribute_name|
          subject.attribute_name = attribute_name
          expect(subject.richtext?).to be false
        end
      end
    end
  end

  describe "#textarea?" do
    context "when column type is `text`" do
      it "returns true" do
        allow(subject).to receive(:column_type).and_return(:text)
        expect(subject.textarea?).to be true
      end
    end

    context "when column type is not `text`" do
      it "returns false" do
        allow(subject).to receive(:column_type).and_return(:asdasd)
        expect(subject.textarea?).to be false
      end
    end
  end

  describe "#text?" do
    context "when column type is `string`" do
      it "returns true" do
        allow(subject).to receive(:column_type).and_return(:string)
        expect(subject.text?).to be true
      end
    end

    context "when column type is not `string`" do
      it "returns false" do
        allow(subject).to receive(:column_type).and_return(:asdasd)
        expect(subject.text?).to be false
      end
    end
  end

  describe "#item?" do
    context "when attribute name ends with `_id` and object has matching association" do
      it "returns true" do
        subject.attribute_name = "author_id"
        expect(subject.item?).to be true
      end
    end

    context "when attribute name ends with `_id` and object hasn't matching association" do
      it "returns false" do
        subject.attribute_name = "author_id"
        allow(Book).to receive(:reflect_on_association).with(:author).and_return(nil)
        expect(subject.item?).to be false
      end
    end

    context "when attribute does not end with `_id`" do
      it "returns false" do
        subject.attribute_name = "cover_asdasdd_uid"
        expect(subject.item?).to be false
      end
    end
  end
end
