class Chapter < ActiveRecord::Base
  validates_presence_of :title, :text, :book
  belongs_to :book
  alias_attribute :to_text, :title
end
