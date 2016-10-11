require 'rails_helper'
describe "Errors hash builder" do
  class DummyResourceValidatorAuthor < Author
    self.table_name = 'authors'
    has_many :books, inverse_of: :author, class_name: :DummyResourceValidatorBook, foreign_key: :author_id
  end

  class DummyResourceValidatorBook < Book
    self.table_name = 'books'
    belongs_to :author, inverse_of: :books, class_name: :DummyResourceValidatorAuthor

    validates_presence_of :author
    accepts_nested_attributes_for :author
  end

  let(:resource) { DummyResourceValidatorBook.new }
  let(:error){ ActiveModel::ErrorMessage.new("blank value", :blank) }

  subject do
    Releaf::BuildErrorsHash.new(resource: resource, field_name_prefix: :resource)
  end

  describe "#format_errors" do
    it "adds error to errors" do
      expected_result = {
        "resource[title]" => [
          {error_code: :blank, message: "can't be blank"},
          {error_code: :invalid, message: "test error"},
        ],
        "resource[author_id]" => [
          {error_code: :blank, message: "can't be blank"},
          {error_code: :invalid, message: "Invalid author"}
        ],
        "resource" => [
          {error_code: :invalid, message: "error on base"}
        ]
      }
      resource.valid?
      resource.chapters.new(id: 12)
      resource.chapters.new(title: 'test')
      resource.errors.add(:base, 'error on base')
      resource.errors.add(:title, "test error")
      resource.errors.add(:author_id, "Invalid author")
      expect(subject.call).to eq(expected_result)

      resource.title = "xxx"
      resource.build_author
      resource.valid?

      expected_result = {
        "resource[chapters_attributes][0][title]" => [
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"}
        ],
        "resource[chapters_attributes][0][text]" => [
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"}
        ],
        "resource[chapters_attributes][0][sample_html]" => [
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"}
        ],
        "resource[chapters_attributes][1][text]" => [
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"}
        ],
        "resource[chapters_attributes][1][sample_html]" => [
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"},
          {error_code: :blank, message: "can't be blank"}
        ],
        "resource[author_attributes][name]" => [
          {error_code: :blank, message: "can't be blank"}
        ]
      }
      expect(subject.call).to eq(expected_result)
    end
  end
end
