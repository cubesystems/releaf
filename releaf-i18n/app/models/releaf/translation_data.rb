module Releaf
  class TranslationData < ActiveRecord::Base

    self.table_name = "releaf_translation_data"

    validates_presence_of :translation, :lang
    validates_uniqueness_of :translation_id, :scope => :lang
    validates_length_of :lang, maximum: 5

    belongs_to :translation, :inverse_of => :translation_data

  end
end
