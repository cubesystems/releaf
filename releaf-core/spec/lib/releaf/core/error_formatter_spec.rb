require 'spec_helper'

describe Releaf::Core::ErrorFormatter do

  class DummyResourceValidatorAuthor < Author
    self.table_name = 'authors'
    has_many :books, inverse_of: :author, class_name: :DummyResourceValidatorBook, foreign_key: :author_id
  end

  class DummyResourceValidatorBook < Book
    self.table_name = 'books'
    belongs_to :author, inverse_of: :books, class_name: :DummyResourceValidatorAuthor

    validates_presence_of :author
    validate :base_validation
    accepts_nested_attributes_for :author

    attr_accessor :add_error_on_base

    def base_validation
      return unless add_error_on_base
      self.errors.add(:base, 'error on base')
    end
  end

  let(:book) {
    b = Book.new
    b.valid?
    b
  }

  subject do
    described_class.new(book, 'resource')
  end

  describe "#errors" do
    it "is a hash" do
      allow_any_instance_of(described_class).to receive(:format_errors)
      expect( subject.errors ).to be_an_instance_of Hash
    end
  end

  describe "#format_errors" do
    let(:book) {
      b = DummyResourceValidatorBook.new
      b.valid?
      b
    }

    def blank_error(attribute, class_name='DummyResourceValidatorBook', id='null')
      {
        error_code: :blank,
        message: "Blank",
        full_message: "#{class_name} with id #{id} has error \"Blank\" on attribute \"#{attribute}\""
      }
    end

    it "is called after initialization" do
      expect_any_instance_of( described_class ).to receive(:format_errors)
      described_class.new(Book.new, 'resource')
    end

    it "doesn't validates resource" do
      expect( book ).to_not receive(:valid?)
      expect( book ).to_not receive(:invalid?)
      subject
    end

    it "correctly adds errors for fields resource fields" do
      expect( subject.errors["resource[title]"] ).to eq [blank_error('title')]
    end

    it "correclty adds errors for missing associated object (belongs_to)" do
      expect( subject.errors["resource[author_id]"] ).to eq [blank_error('author')]
    end

    it "correctly adds error for missing associated object attributes (belongs_to)" do
      book.build_author
      book.valid?
      expect( subject.errors["resource[author_attributes][name]"] ).to eq [blank_error('name', 'DummyResourceValidatorAuthor')]
    end

    it "correctly adds error for missing associated object attributes (has_many)" do
      book.chapters.new(id: 12)
      book.chapters.new(:title => 'test')
      book.valid?
      expect( subject.errors["resource[chapters_attributes][0][title]"] ).to eq [blank_error('title', 'Chapter', '12')]
      expect( subject.errors["resource[chapters_attributes][1][title]"] ).to be_nil

      expect( subject.errors["resource[chapters_attributes][0][text]"] ).to eq [blank_error('text', 'Chapter', '12')]
      expect( subject.errors["resource[chapters_attributes][1][text]"] ).to eq [blank_error('text', 'Chapter')]
    end

    it "handles errors on base" do
      book.add_error_on_base = true
      book.valid?
      expect( subject.errors["resource"] ).to eq [{
        error_code: :invalid,
        message: "Error on base",
        full_message: 'DummyResourceValidatorBook with id null has error "error on base"'
      }]
    end
  end

  describe "#association" do
    it "returns active record reflection of association" do
      expect( subject.send(:association, 'author') ).to eq Book.reflect_on_association(:author)
    end
  end

  describe "#association_type" do
    it "returns active record reflection macro" do
      expect( subject.send(:association_type, 'author') ).to eq :belongs_to
    end
  end

  describe "#single_association?" do
    context "for :belongs_to association" do
      it "returns true" do
        expect( subject.send(:single_association?, 'author') ).to be true
      end
    end

    context "for :has_many association" do
      it "returns false" do
        expect( subject.send(:single_association?, 'chapters') ).to be false
      end
    end

    context "for :has_one association" do
      it "returns true" do
        allow(subject).to receive(:association_type).with('author').and_return(:has_one)
        expect( subject.send(:single_association?, 'author') ).to be true
      end
    end
  end

  describe "#models_attribute?" do
    context "when attribute name contains dot" do
      it "returns false" do
        expect( subject.send(:models_attribute?, 'test.attribute') ).to be false
      end
    end

    context "when attribute name doesn't contain dot" do
      it "returns true" do
        expect( subject.send(:models_attribute?, 'test') ).to be true
      end
    end
  end

  describe "#field_id" do
    context "when error is on base" do
      it "returns resource field_id" do
        expect( subject.send(:field_id, 'base') ).to eq 'resource'
      end
    end

    context "when attribute is association" do
      it "returns field_id for associations foreign key" do
        expect( subject.send(:field_id, 'author') ).to eq 'resource[author_id]'
      end
    end

    context "when attribute is not association" do
      it "returns field_id for field" do
        expect( subject.send(:field_id, 'title') ).to eq 'resource[title]'
      end
    end
  end

  describe "#add_error" do
    before do
      # prevent formatting errors when class is initialized
      allow_any_instance_of(described_class).to receive(:format_errors)
    end

    it "adds error to errors" do
      expected_result = {
        'resource[title]' => [
          {
            error_code: 'test error',
            message: 'Error message',
            full_message: 'Book with id null has error "error message" on attribute "title"'
          },
          {
            error_code: 'test error',
            message: 'Jet another error message',
            full_message: 'Book with id null has error "jet another error message" on attribute "title"'
          }
        ],
        'resource[author_id]' => [
          {
            error_code: 'invalid',
            message: 'Invalid author',
            full_message: 'Book with id null has error "invalid author" on attribute "author"',
            data: {foo: :bar}
          }
        ]
      }

      message = ActiveModel::ErrorMessage.new("error message")
      allow(message).to receive(:error_code).and_return('test error')
      allow(message).to receive(:data).and_return(nil)

      other_message = ActiveModel::ErrorMessage.new("invalid author")
      allow(other_message).to receive(:error_code).and_return('invalid')
      allow(other_message).to receive(:data).and_return({foo: :bar})

      jet_another_message = ActiveModel::ErrorMessage.new("jet another error message")
      allow(jet_another_message).to receive(:error_code).and_return('test error')
      allow(jet_another_message).to receive(:data).and_return(nil)

      expect do
        subject.send(:add_error, 'title', message)
        subject.send(:add_error, 'author', other_message)
        subject.send(:add_error, 'title', jet_another_message)
      end.to change { subject.errors }.from({}).to(expected_result)
    end

    it "localizes error messages" do
      message = ActiveModel::ErrorMessage.new("error message")
      allow(message).to receive(:error_code).and_return('test error')
      allow(message).to receive(:data).and_return(nil)

      expect( I18n ).to receive(:t).with(message, scope: "activerecord.errors.messages.book").and_call_original

      template = "%{class} with id %{id} has error \"error message\" on attribute \"%{attribute}\""
      expect( I18n ).to receive(:t).with(template, {
        default: template,
        attribute: 'title',
        class: 'Book',
        id: 'null',
        scope: "activerecord.errors.messages.book"
      }).and_call_original

      subject.send(:add_error, 'title', message)
    end
  end


end
