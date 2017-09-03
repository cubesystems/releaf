require 'axlsx_rails'
require 'i18n'
require 'rails-i18n'
require 'roo'

module Releaf::I18nDatabase
  require 'releaf/i18n_database/engine'
  require 'releaf/i18n_database/configuration'
  require 'releaf/i18n_database/humanize_missing_translations'
  require 'releaf/i18n_database/backend'

  def self.components
    [Releaf::I18nDatabase::Backend, Releaf::I18nDatabase::HumanizeMissingTranslations]
  end
end
