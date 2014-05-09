module Releaf
  class Translation < ActiveRecord::Base
    self.table_name = "releaf_translations"

    validates_presence_of :key
    validates_uniqueness_of :key
    validates_length_of :key, maximum: 255

    has_many :translation_data, :dependent => :destroy, :class_name => 'Releaf::TranslationData', :inverse_of => :translation
    accepts_nested_attributes_for :translation_data, :allow_destroy => true
  end
end
