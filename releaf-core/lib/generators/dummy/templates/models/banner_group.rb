class BannerGroup < ActiveRecord::Base
  dragonfly_accessor :image
  validates_presence_of :title
  belongs_to :home_page

  has_many :banners, -> { order(:item_position) },  dependent: :destroy
  accepts_nested_attributes_for :banners, allow_destroy: true
end
