require 'i18n'

module I18n
  module UseKeyForMissing
    def call(exception, locale, key, options)
      if exception.is_a?(I18n::MissingTranslation)
        key.to_s.split('.').last.humanize
      else
        super
      end
    end
  end
end

I18n.exception_handler.extend I18n::UseKeyForMissing

I18N_CACHE = ActiveSupport::Cache::MemoryStore.new
require 'i18n/backend/releaf'
I18n.backend = I18n::Backend::Releaf.new
