class Book < ActiveRecord::Base
  belongs_to :author
  has_many :chapters, inverse_of: :book
  has_many :book_sequels, dependent: :destroy
  has_many :sequels, through: :book_sequels

  validates_presence_of :title

  translates :description
  globalize_accessors

  # chapters may not be destroy
  accepts_nested_attributes_for :chapters
  accepts_nested_attributes_for :book_sequels, allow_destroy: true

  dragonfly_accessor :cover_image

  alias_attribute :to_text, :title
end
