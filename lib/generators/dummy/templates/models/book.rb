class Book < ActiveRecord::Base
  include Releaf::BooleanAt

  boolean_at :published_at

  attr_accessible :title, :year, :author_id, :year, :author, :genre, :summary_html, :active, :published, :published_at
  validates_presence_of :title
  belongs_to :author


  alias_attribute :to_text, :title
end
