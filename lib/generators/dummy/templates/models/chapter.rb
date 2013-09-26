class Chapter < ActiveRecord::Base
  attr_accessible :title, :text
  validates_presence_of :title, :text, :book
  belongs_to :book
  alias_attribute :to_text, :title
end
