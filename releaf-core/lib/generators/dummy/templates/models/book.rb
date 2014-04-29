class Book < ActiveRecord::Base
  include Releaf::RichtextAttachments

  belongs_to :author
  has_many :chapters, inverse_of: :book

  validates_presence_of :title

  translates :description
  globalize_accessors

  # chapters may not be destroy
  accepts_nested_attributes_for :chapters

  dragonfly_accessor :cover_image

  alias_attribute :to_text, :title

  def price
    stored_price = super
    return nil if stored_price.blank?
    return stored_price / 100.0
  end

  def price=(new_val)
    return super if new_val.blank?
    return super(new_val * 100)
  end
end
