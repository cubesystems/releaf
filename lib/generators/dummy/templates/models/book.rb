class Book < ActiveRecord::Base
  include Releaf::RichtextAttachments

  validates_presence_of :title
  belongs_to :author
  has_many :chapters
  alias_attribute :to_text, :title

  accepts_nested_attributes_for :chapters, :allow_destroy => true

  attr_accessible :title, :year, :author_id, :year, :author, :genre, :summary_html, :active, :published, :published_at, :chapters_attributes, :price


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
