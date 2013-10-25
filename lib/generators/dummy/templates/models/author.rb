class Author < ActiveRecord::Base
  validates_presence_of :name

  has_many :books, dependent: :restrict

  def to_text
    return "#{name} #{surname}"
  end
end
