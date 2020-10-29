module Releaf::I18nDatabase
  module HumanizeMissingTranslations
    def call(exception, locale, key, options)
      if key.present? && exception.is_a?(I18n::MissingTranslation)
        key.to_s.split('.').last.humanize
      else
        super
      end
    end

    def self.initialize_component
      I18n.exception_handler.extend(self)
    end
  end
end
