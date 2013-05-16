require 'active_record'

module I18n
  module Backend
    class Releaf
      class Translation < ::ActiveRecord::Base

        self.table_name = "releaf_translations"

        validates_presence_of :group_id, :key
        validates_uniqueness_of :key, :scope => :group_id

        belongs_to :translation_group, :foreign_key => :group_id
        has_many :translation_data, :dependent => :destroy, :class_name => 'Releaf::TranslationData'

        attr_accessible \
          :group_id,
          :key

        scope :joined, select('releaf_translations.*, releaf_translation_data.lang as "lang", releaf_translation_data.localization as "localization", releaf_translation_groups.scope as "scope"').
          joins(:translation_data, :translation_group)

        scope :get_translated, joined.where('releaf_translation_data.lang IS NOT NULL');

        scope :lookup, lambda { |locale, keys, scope|
          joined.where('releaf_translation_groups.scope = :scope AND releaf_translation_data.lang = :locale AND releaf_translations.key in (:keys)', :keys => keys, :locale => locale, :scope => scope)
        }
        scope :filter, lambda{ |params|
          translations_join = 'LEFT OUTER JOIN `releaf_translation_data` ON `releaf_translations`.`id` = `releaf_translation_data`.`translation_id`'
          where( '(releaf_translations.key LIKE ? OR releaf_translation_data.localization LIKE ?)', "%#{params[:search]}%", "%#{params[:search]}%" ).joins(translations_join).group('releaf_translations.id') unless params[:search].blank?
        }

        def locales
          values = {}

          valid_locales = Settings.i18n_locales || []
          valid_locales += Settings.i18n_admin_locales || []

          valid_locales.uniq.each do |locale|
            values[locale] = nil
          end

          translation_data.find_each do |value|
            values[value.lang] = value.localization if values.has_key? value.lang
          end

          values
        end

        def plain_key
          key.gsub(translation_group.scope + '.', '')
        end

      end
    end
  end
end

