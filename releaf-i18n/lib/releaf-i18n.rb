require 'i18n'
require 'i18n/engine'
require 'i18n/humanize_missing_translations'
require 'i18n/backend/releaf'
I18n.exception_handler.extend I18n::HumanizeMissingTranslations
I18n.backend = I18n::Backend::Releaf.new
