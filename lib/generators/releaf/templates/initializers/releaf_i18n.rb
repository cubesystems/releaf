module UseKeyForMissing
  def call(exception, locale, key, options)
    if exception.is_a?(I18n::MissingTranslation)
      key.to_s.split('.').last.humanize
    else
      super
    end
  end
end
I18n.exception_handler.extend UseKeyForMissing





I18N_CACHE = ActiveSupport::Cache::MemoryStore.new
require 'i18n/backend/releaf'
I18n.backend = I18n::Backend::Releaf.new

# skip cache loading for rake tasks and cucumber (ex. migrations)
if !($0.end_with?('rake') || $0.end_with?('cucumber'))
  I18n.backend.reload_cache
end


