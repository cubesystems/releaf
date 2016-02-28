class Releaf::I18nDatabase::TranslationsStore
  include Releaf::InstanceCache
  attr_accessor :updated_at, :missing_keys

  def initialize
    self.updated_at = Releaf::I18nDatabase::Backend.translations_updated_at
    self.missing_keys = {}
  end

  def expired?
    updated_at != Releaf::I18nDatabase::Backend.translations_updated_at
  end

  def exist?(key)
    stored_keys.key? key
  end

  def add(locale, data)
    new_hash = {}
    new_hash[locale] = data

    stored_translations.deep_merge!(new_hash)
    self.missing_keys = {}
  end

  def lookup(locale, key, options)
    translation_keys = key.split('.')

    (1..translation_keys.length).each do|i|
      result = dig_valid_translation(locale, translation_keys, i == 1, options)
      return result if returnable_result?(result, options)
      # remove second last value (going up to scope chain)
      translation_keys.delete_at(translation_keys.length - 2)
    end

    nil
  end

  def dig_translation(locale, translation_keys)
    translation_keys.inject(stored_translations[locale.to_sym]) do |h, key|
      h[key.to_sym] if h.is_a?(Hash)
    end
  end

  def dig_valid_translation(locale, translation_keys, first_lookup, options)
    result = dig_translation(locale, translation_keys)
    if invalid_result?(locale, result, first_lookup, options)
      nil
    else
      result
    end
  end

  def invalid_result?(locale, result, first_lookup, options)
    invalid_nonpluralized_result?(result, first_lookup, options) || invalid_pluralized_result?(locale, result, options)
  end

  def invalid_nonpluralized_result?(result, first_lookup, options)
    result.is_a?(Hash) && !first_lookup && !options.has_key?(:count)
  end

  def invalid_pluralized_result?(locale, result, options)
    result.is_a?(Hash) && options.has_key?(:count) && !valid_pluralized_result?(locale, options[:count], result)
  end

  def valid_pluralized_result?(locale, count, result)
    return false unless TwitterCldr.supported_locale?(locale)
    result.key?(TwitterCldr::Formatters::Plurals::Rules.rule_for(count, locale))
  end

  def returnable_result?(result, options)
    result.present? || options.fetch(:inherit_scopes, true) == false
  end

  def localization_data
    Releaf::I18nDatabase::I18nEntryTranslation
      .joins(:i18n_entry)
      .where.not(text: '')
      .pluck("CONCAT(locale, '.', releaf_i18n_entries.key) AS translation_key", "text")
      .to_h
  end

  def stored_keys
    Releaf::I18nDatabase::I18nEntry.pluck(:key).inject({}) do|h, key|
      h.update(key => true)
    end
  end

  def stored_translations
    stored_keys.map do |key, _|
      key_hash(key)
    end.inject(&:deep_merge) || {}
  end

  def key_hash(key)
    Releaf.application.config.all_locales.inject({}) do |h, locale|
      localized_key = "#{locale}.#{key}"
      locale_hash = key_locale_hash(localized_key, localization_data[localized_key])
      h.merge(locale_hash)
    end
  end

  def missing?(locale, key)
    missing_keys.key? "#{locale}.#{key}"
  end

  def missing(locale, key, options)
    # mark translation as missing
    missing_keys["#{locale}.#{key}"] = true
    create_missing(key, options) if create_missing?(key, options)
  end

  def locales_pluralizations
    Releaf.application.config.all_locales.map do|locale|
      TwitterCldr::Formatters::Plurals::Rules.all_for(locale) if TwitterCldr.supported_locale?(locale)
    end.flatten.uniq.compact
  end

  def create_missing?(key, options)
    return false unless Releaf.application.config.i18n_database.create_missing_translations
    return false if options[:create_missing] == false
    return false if stored_keys.key?(key)
    true
  end

  def create_missing(key, options)
    if pluralizable_translation?(options)
      locales_pluralizations.each do|pluralization|
        Releaf::I18nDatabase::I18nEntry.create(key: "#{key}.#{pluralization}")
      end
    else
      Releaf::I18nDatabase::I18nEntry.create(key: key)
    end
  end

  def pluralizable_translation?(options)
    options.has_key?(:count) && options[:create_plurals] == true
  end

  cache_instance_methods :stored_translations, :stored_keys, :localization_data

  private

  def key_locale_hash(localized_key, localization)
    localized_key.split(".").reverse.inject(localization) do |value, key|
      {key.to_sym => value}
    end
  end
end
