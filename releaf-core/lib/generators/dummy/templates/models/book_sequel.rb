class BookSequel < ActiveRecord::Base
  belongs_to :book
  has_one :sequel, class_name: 'Book'
end
