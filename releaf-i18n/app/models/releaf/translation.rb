module Releaf
  class Translation < ActiveRecord::Base
    self.table_name = "releaf_translations"

    validates_presence_of :key
    validates_uniqueness_of :key
    validates_length_of :key, maximum: 255

    has_many :translation_data, :dependent => :destroy, :class_name => 'Releaf::TranslationData', :inverse_of => :translation
    accepts_nested_attributes_for :translation_data, :allow_destroy => true

    def locales
      values = {}

      valid_locales = ::Releaf.available_locales || []
      valid_locales += ::Releaf.available_admin_locales || []
      valid_locales += ::I18n.available_locales || []

      valid_locales.map(&:to_s).uniq.each do |locale|
        values[locale] = nil
      end

      translation_data.each do |value|
        values[value.lang] = value.localization if values.has_key? value.lang
      end

      values
    end
  end
end
