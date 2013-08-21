require 'i18n'
require 'i18n/use_key_for_missing'
require 'i18n/backend/releaf'
I18n.exception_handler.extend I18n::UseKeyForMissing
I18n.backend = I18n::Backend::Releaf.new
