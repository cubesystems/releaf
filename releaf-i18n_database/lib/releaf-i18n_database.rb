require 'twitter_cldr'
require 'i18n'
require 'releaf/i18n_database/engine'
require 'releaf/i18n_database/humanize_missing_translations'
require 'releaf/i18n_database/backend'
I18n.exception_handler.extend Releaf::I18nDatabase::HumanizeMissingTranslations
I18n.backend = Releaf::I18nDatabase::Backend.new
