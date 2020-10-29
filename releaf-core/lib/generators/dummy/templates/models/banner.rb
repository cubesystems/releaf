class Banner < ActiveRecord::Base
  dragonfly_accessor :image
  validates_presence_of :url
  belongs_to :banner_group, required: false

  def releaf_title
    url
  end
end
