module Releaf::I18nDatabase
  class I18nEntryTranslation < ActiveRecord::Base
    self.table_name = "releaf_i18n_entry_translations"

    validates_presence_of :i18n_entry, :locale
    validates_uniqueness_of :i18n_entry_id, scope: :locale
    validates_length_of :locale, maximum: 5

    belongs_to :i18n_entry, inverse_of: :i18n_entry_translation
  end
end
