class Author < ActiveRecord::Base
  has_many :books
  attr_accessible :name, :surname, :bio, :birth_date, :wiki_link
  validates_presence_of :name

  def to_text
    return "#{name} #{surname}"
  end
end
