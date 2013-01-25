I18N_CACHE = ActiveSupport::Cache::MemoryStore.new
require 'i18n/backend/leaf'
I18n.backend = I18n::Backend::Leaf.new

# skip cache loading for rake tasks and cucumber (ex. migrations)
if !($0.end_with?('rake') || $0.end_with?('cucumber'))
  I18n.backend.reload_cache
end
