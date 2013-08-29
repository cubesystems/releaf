class Book < ActiveRecord::Base
  attr_accessible :title, :year, :author_id, :year, :author, :genre, :summary_html, :active, :published, :published_at
  validates_presence_of :title
  belongs_to :author
  alias_attribute :to_text, :title
end
