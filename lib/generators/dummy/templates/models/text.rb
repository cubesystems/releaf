class Text < ActiveRecord::Base
  acts_as_node

  validates_presence_of :text_html

  alias_attribute :to_text, :id

  attr_accessible \
    :text_html
end
