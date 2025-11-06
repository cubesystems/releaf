class Book < ActiveRecord::Base
  belongs_to :author, optional: true
  has_many :chapters, -> { order(:item_position) }, inverse_of: :book
  has_many :book_sequels, dependent: :destroy
  has_many :sequels, through: :book_sequels

  validates_presence_of :title

  # chapters may not be destroy
  accepts_nested_attributes_for :chapters
  accepts_nested_attributes_for :book_sequels, allow_destroy: true

  dragonfly_accessor :cover_image
end
