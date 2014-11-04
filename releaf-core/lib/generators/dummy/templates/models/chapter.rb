# TODO convert to arel
class Chapter < ActiveRecord::Base
  validates_presence_of :title, :text, :book, :sample_html
  belongs_to :book
  alias_attribute :to_text, :title
  default_scope { order('chapters.item_position ASC') }
end
