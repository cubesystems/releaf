module Releaf
  module Globalize3
    module Fallbacks
      def self.set
        i18n_fallbacks = {}

        I18n.default_locale ||= 'en'
        I18n.locale ||= 'en'

        valid_locales = Settings.i18n_locales || []

        (valid_locales + [I18n.default_locale, I18n.locale]).uniq.each do |locale|
          i18n_fallbacks[locale] = valid_locales - [locale]
        end
        Globalize.fallbacks = i18n_fallbacks
      end
    end
  end
end
