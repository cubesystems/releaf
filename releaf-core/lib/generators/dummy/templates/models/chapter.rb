class Chapter < ActiveRecord::Base
  validates_presence_of :title, :text, :book, :sample_html
  belongs_to :book
  default_scope { order('chapters.item_position ASC') }
end
