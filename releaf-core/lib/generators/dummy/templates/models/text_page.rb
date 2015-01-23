class TextPage < ActiveRecord::Base
  acts_as_node permit_attributes: [:text_html]

  validates_presence_of :text_html

  alias_attribute :to_text, :id
end
