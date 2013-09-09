class Author < ActiveRecord::Base
  attr_accessible :name, :surname, :bio, :birth_date, :wiki_link
  validates_presence_of :name

  has_many :books, dependent: :restrict

  def to_text
    return "#{name} #{surname}"
  end
end
