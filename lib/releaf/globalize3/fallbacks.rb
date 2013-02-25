module Releaf
  module Globalize3
    module Fallbacks
      def self.set
        i18n_fallbacks = {}

        I18n.default_locale ||= 'en'
        I18n.locale ||= 'en'

        Settings.i18n_locales + [I18n.default_locale, I18n.locale].each do |locale|
          i18n_fallbacks[locale] = Settings.i18n_locales - [locale]
        end
        Globalize.fallbacks = i18n_fallbacks
      end
    end
  end
end
