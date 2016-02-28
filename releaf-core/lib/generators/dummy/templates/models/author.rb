class Author < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :publisher

  has_many :books, dependent: :restrict_with_exception

  def releaf_title
    "#{name} #{surname}"
  end
end
