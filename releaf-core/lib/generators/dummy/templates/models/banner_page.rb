class BannerPage < ActiveRecord::Base
  acts_as_node
  has_many :banner_groups, -> { order(:item_position) }, dependent: :destroy
  accepts_nested_attributes_for :banner_groups, allow_destroy: true
  dragonfly_accessor :top_banner
  dragonfly_accessor :bottom_banner
end
