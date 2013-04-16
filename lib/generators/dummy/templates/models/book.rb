class Book < ActiveRecord::Base
  attr_accessible :title, :year, :author_id
  validates_presence_of :title
end
