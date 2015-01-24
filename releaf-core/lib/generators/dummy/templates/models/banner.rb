class Banner < ActiveRecord::Base
  dragonfly_accessor :banner
  validates_presence_of :url
  belongs_to :home_page
end
