require 'spec_helper'

describe Releaf::ResourceValidator do
  let(:book) { Book.new }
  subject do
    Releaf::ResourceValidator.new(book, 'test', 'resource')
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

      expect( I18n ).to receive(:t).with(message,  scope: "validation.test").and_call_original
      subject.send(:add_error, 'title', message)
    end
  end


end
