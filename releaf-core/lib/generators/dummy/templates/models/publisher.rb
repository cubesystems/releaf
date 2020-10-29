class Publisher < ActiveRecord::Base
  validates_presence_of :title
  has_many :authors, dependent: :restrict_with_exception
end
