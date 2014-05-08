module Releaf
  class TranslationProxy
    attr_accessor :localizations, :key, :destroy, :translation, :localization_ids, :id

    def initialize translation=nil
      self.localizations = {}
      self.localization_ids = {}

      if translation
        self.translation = translation
        self.key = translation.key
        self.id = translation.id
        locales.each do |locale|
          next unless translation.respond_to? "#{locale}_localization"
          self.localizations[locale] = translation.send("#{locale}_localization")
          self.localization_ids[locale] = translation.send("#{locale}_localization_id")
        end
      end
    end

    def translation
      return @translation if @translation
      @translation = Translation.find_or_initialize_by(key: key)
    end

    def save
      translation.update_attributes!({
        key: key,
        translation_data_attributes: translation_data_attributes,
      })
    rescue ActiveRecord::RecordInvalid
      return false
    else
      return true
    end

    def destroy
      return if translation.new_record?
      translation.destroy!
    end

    # protected

    def locales
      Releaf.all_locales
    end

    def translation_data_attributes
      hsk = {}
      locales.each_with_index do |locale, i|
        hsk[i] = {
          localization: localizations[locale],
          lang: locale,
        }
        unless translation.new_record?
          hsk[i][:id] = localization_ids.fetch(locale, get_localization_record_id(locale))
        end
      end
      return hsk
    end

    def get_localization_record_id locale
      translation.translation_data.find_by_lang(locale).try(:id)
    end

  end
end
