require "spec_helper"

describe Releaf::RichtextAttachments do
  class AuthorWithAttachments < Author
    include Releaf::RichtextAttachments
  end

  let (:html_snippet_with_2_attachments) do
    'some simple content <a href="/no/where" data-attachment-id="%s">link to nowhere<\a> <img src="/test/image" data-attachment-id="%s" />'
  end

  let (:html_snippet_with_1_attachment) do
    'some simple content <a href="/no/where" data-attachment-id="%s">link to nowhere'
  end


  it "is included in Book model" do
    expect( Book.included_modules ).to include subject
  end

  it "is not included in Author model" do
    expect( Author.included_modules ).to_not include subject
  end

  it "creates attachments relation" do
    expect( Book.reflect_on_association :attachments ).to_not be_nil
  end

  describe "#richtext_columns" do
    context 'when richtext fields are present' do
      it "returns richtext column names" do
        expect( Book.new.send(:richtext_columns) ).to eq ['summary_html']
      end
    end

    context 'when richtext fields are not present' do
      it "returns empty array" do
        expect( AuthorWithAttachments.new.send(:richtext_columns) ).to eq []
      end
    end
  end

  describe "#richtext_attachment_collected_uuids" do
    it "returns all richtext field content data-attachment-id attribute values" do
      uuid_1 = "550e8400-e29b-41d4-a716-446655440000"
      uuid_2 = "550e8400-e29b-41d4-a716-446655440001"

      book = Book.new do |b|
        b.summary_html = html_snippet_with_2_attachments % [uuid_1, uuid_2]
      end

      expect( book.send(:richtext_attachment_collected_uuids) ).to have(2).uuids
      expect( book.send(:richtext_attachment_collected_uuids) ).to include(uuid_1, uuid_2)
    end

    it "calls #richtext_columns" do
      book = Book.new
      book.should_receive(:richtext_columns).once.and_return([])
      book.send(:richtext_attachment_collected_uuids)
    end
  end

  describe "#manage_attachments" do
    let(:book) { Book.new FactoryGirl.attributes_for :book }
    let(:image) { Rack::Test::UploadedFile.new(File.expand_path('../fixtures/cs.png', __dir__), "image/png") }
    let(:file) { Rack::Test::UploadedFile.new(File.expand_path('../fixtures/time.formats.xlsx', __dir__), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }

    let(:attachment_1) do
      Releaf::Attachment.create( :file => file )
    end
    let(:attachment_2) do
      Releaf::Attachment.create( :file => image )
    end

    it "is called after save" do
      book.should_receive(:manage_attachments).once
      book.save!
    end
    
    it "calls #richtext_attachment_collected_uuids" do
      book.should_receive(:richtext_attachment_collected_uuids).once
      book.send(:manage_attachments)
    end

    context "when new attachments are detected" do
      it "assigns new attachments to book" do
        book.summary_html = html_snippet_with_2_attachments % [attachment_1.uuid, attachment_2.uuid]

        expect( attachment_1.richtext_attachment_type ).to be_nil
        expect( attachment_1.richtext_attachment_id ).to be_nil
        expect( attachment_2.richtext_attachment_type ).to be_nil
        expect( attachment_2.richtext_attachment_id ).to be_nil

        expect { book.save! }.to change { book.attachments.count }.from(0).to(2)
        attachment_1.reload
        attachment_2.reload

        expect( attachment_1.richtext_attachment_type ).to eq 'Book'
        expect( attachment_1.richtext_attachment_id ).to eq book.id
        expect( attachment_2.richtext_attachment_type ).to eq 'Book'
        expect( attachment_2.richtext_attachment_id ).to eq book.id
      end
    end

    context "when some attachments are removed" do
      before do
        book.summary_html = html_snippet_with_2_attachments % [attachment_1.uuid, attachment_2.uuid]

        expect( attachment_1.richtext_attachment_type ).to be_nil
        expect( attachment_1.richtext_attachment_id ).to be_nil
        expect( attachment_2.richtext_attachment_type ).to be_nil
        expect( attachment_2.richtext_attachment_id ).to be_nil

        book.save!
        attachment_1.reload
        attachment_2.reload
      end

      it "deletes removed attachments" do
        expect( attachment_1.richtext_attachment_type ).to eq 'Book'
        expect( attachment_1.richtext_attachment_id ).to eq book.id
        expect( attachment_2.richtext_attachment_type ).to eq 'Book'
        expect( attachment_2.richtext_attachment_id ).to eq book.id

        book.summary_html = html_snippet_with_1_attachment % attachment_1.uuid
        expect { book.save! }.to change { book.attachments.count }.from(2).to(1)

        expect( attachment_1.richtext_attachment_type ).to eq 'Book'
        expect( attachment_1.richtext_attachment_id ).to eq book.id

        expect( Releaf::Attachment.where(:uuid => attachment_2.uuid).exists? ).to be_false
      end
    end

    context "when attachments didn't change" do
      before do
        book.summary_html = html_snippet_with_2_attachments % [attachment_1.uuid, attachment_2.uuid]

        book.save!
        attachment_1.reload
        attachment_2.reload
      end

      it "does nothing" do
        expect( attachment_1.richtext_attachment_type ).to eq 'Book'
        expect( attachment_1.richtext_attachment_id ).to eq book.id
        expect( attachment_2.richtext_attachment_type ).to eq 'Book'
        expect( attachment_2.richtext_attachment_id ).to eq book.id

        book.title += ' 2'

        expect { book.save! }.to_not change { book.attachments.count }

        attachment_1.reload
        attachment_2.reload

        expect( attachment_1.richtext_attachment_type ).to eq 'Book'
        expect( attachment_1.richtext_attachment_id ).to eq book.id
        expect( attachment_2.richtext_attachment_type ).to eq 'Book'
        expect( attachment_2.richtext_attachment_id ).to eq book.id
      end
    end
  end

end
