class Author < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :publisher

  has_many :books, dependent: :restrict_with_exception

  def to_text
    return "#{name} #{surname}"
  end
end
