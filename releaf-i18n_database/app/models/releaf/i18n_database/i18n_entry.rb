module Releaf::I18nDatabase
  class I18nEntry < ActiveRecord::Base
    self.table_name = "releaf_i18n_entries"

    validates_presence_of :key
    validates_uniqueness_of :key
    validates_length_of :key, maximum: 255

    has_many :i18n_entry_translation, dependent: :destroy,
      class_name: 'Releaf::I18nDatabase::I18nEntryTranslation', inverse_of: :i18n_entry
    accepts_nested_attributes_for :i18n_entry_translation, allow_destroy: true

    def locale_value(locale)
      find_or_initialize_translation(locale).text
    end

    def find_or_initialize_translation(locale)
      i18n_entry_translation.find{ |translation| translation.locale == locale.to_s } || i18n_entry_translation.build(locale: locale)
    end
  end
end
