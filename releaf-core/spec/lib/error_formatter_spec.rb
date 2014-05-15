require 'spec_helper'

describe Releaf::ErrorFormatter do

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
      described_class.any_instance.stub(:format_errors)
      expect( subject.errors ).to be_an_instance_of Hash
    end
  end

  describe "#format_errors" do
    let(:book) {
      b = DummyResourceValidatorBook.new
      b.valid?
      b
    }
    let(:blank_error) { {error_code: :blank, full_message: "Blank"} }

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
      expect( subject.errors["resource[title]"] ).to eq [blank_error]
    end

    it "correclty adds errors for missing associated object (belongs_to)" do
      expect( subject.errors["resource[author_id]"] ).to eq [blank_error]
    end

    it "correctly adds error for missing associated object attributes (belongs_to)" do
      book.build_author
      book.valid?
      expect( subject.errors["resource[author_attributes][name]"] ).to eq [blank_error]
    end

    it "correctly adds error for missing associated object attributes (has_many)" do
      book.chapters.new
      book.chapters.new(:title => 'test')
      book.valid?
      expect( subject.errors["resource[chapters_attributes][0][title]"] ).to eq [blank_error]
      expect( subject.errors["resource[chapters_attributes][1][title]"] ).to be_nil

      expect( subject.errors["resource[chapters_attributes][0][text]"] ).to eq [blank_error]
      expect( subject.errors["resource[chapters_attributes][1][text]"] ).to eq [blank_error]
    end

    it "handles errors on base" do
      book.add_error_on_base = true
      book.valid?
      expect( subject.errors["resource"] ).to eq [{error_code: :invalid, full_message: "Error on base"}]
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
        expect( subject.send(:single_association?, 'author') ).to be_true
      end
    end

    context "for :has_many association" do
      it "returns false" do
        expect( subject.send(:single_association?, 'chapters') ).to be_false
      end
    end

    context "for :has_one association" do
      it "returns true" do
        subject.stub(:association_type).with('author').and_return(:has_one)
        expect( subject.send(:single_association?, 'author') ).to be_true
      end
    end
  end

  describe "#models_attribute?" do
    context "when attribute name contains dot" do
      it "returns false" do
        expect( subject.send(:models_attribute?, 'test.attribute') ).to be_false
      end
    end

    context "when attribute name doesn't contain dot" do
      it "returns true" do
        expect( subject.send(:models_attribute?, 'test') ).to be_true
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
      described_class.any_instance.stub(:format_errors)
    end

    it "adds error to errors" do
      message = "error message"
      message.stub(:error_code).and_return('test error')

      other_message = "invalid author"
      other_message.stub(:error_code).and_return('invalid')

      jet_another_message = "jet another error message"
      jet_another_message.stub(:error_code).and_return('test error')

      expect do
        subject.send(:add_error, 'title', message)
        subject.send(:add_error, 'author', other_message)
        subject.send(:add_error, 'title', jet_another_message)
      end.to change { subject.errors }.from({}).to({
        'resource[title]' => [
          {error_code: 'test error', full_message: 'Error message'},
          {error_code: 'test error', full_message: 'Jet another error message'},
        ],
        'resource[author_id]' => [
          {error_code: 'invalid', full_message: 'Invalid author'},
        ],
      })
    end

    it "localizes error messages" do
      message = "error message"
      message.stub(:error_code).and_return('test error')

      expect( I18n ).to receive(:t).with(message, scope: "activerecord.errors.messages.book").and_call_original
      subject.send(:add_error, 'title', message)
    end
  end


end
