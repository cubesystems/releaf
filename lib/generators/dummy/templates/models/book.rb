class Book < ActiveRecord::Base
  include Releaf::RichtextAttachments

  belongs_to :author
  has_many :chapters

  validates_presence_of :title

  accepts_nested_attributes_for :chapters, :allow_destroy => true

  image_accessor :cover_image

  attr_accessible \
    :active,
    :author,
    :author_id,
    :chapters_attributes,
    :genre,
    :price,
    :published,
    :published_at,
    :summary_html,
    :title,
    :year,
    :cover_image,
    :retained_cover_image,
    :remove_cover_image

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
