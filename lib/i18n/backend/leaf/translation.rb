require 'active_record'

module I18n
  module Backend
    class Leaf
      class Translation < ::ActiveRecord::Base

        validates_presence_of :group_id, :key
        validates_uniqueness_of :key, :scope => :group_id
        belongs_to :translation_group, :foreign_key => :group_id
        has_many :translation_data, :dependent => :destroy, :class_name => 'Leaf::TranslationData'

        scope :joined, select('translations.*, translation_data.lang as "lang", translation_data.localization as "localization", translation_groups.scope as "scope"').
          joins(:translation_data, :translation_group)

        scope :get_translated, joined.where('translation_data.lang IS NOT NULL');

        scope :lookup, lambda { |locale, keys, scope|
          joined.where('translation_groups.scope = :scope AND translation_data.lang = :locale AND translations.key in (:keys)', :keys => keys, :locale => locale, :scope => scope)
        }
        scope :filter, lambda{ |params|
          where( 'translations.key LIKE ?', "%#{params[:search]}%" ) unless params[:search].blank?
        }

        after_commit :reload_cache

        def locales
          values = {}
          Settings.i18n_locales.each do |locale|
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

        private

        def reload_cache
          Settings.i18n_updated_at = Time.now
          I18n.backend.reload_cache
        end
      end
    end
  end
end

