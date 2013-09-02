require 'active_record'

module I18n
  module Backend

    class Releaf
      class Translation < ::ActiveRecord::Base
        before_save :reassign_scope

        self.table_name = "releaf_translations"

        validates_presence_of :translation_group, :key
        validates_uniqueness_of :key

        belongs_to :translation_group, :foreign_key => :group_id, :inverse_of => :translations
        has_many :translation_data, :dependent => :destroy, :class_name => 'Releaf::TranslationData', :inverse_of => :translation
        accepts_nested_attributes_for :translation_data, :allow_destroy => true

        attr_accessible \
          :group_id,
          :key,
          :translation_data_attributes

        def locales
          values = {}

          valid_locales = ::Releaf.available_locales || []
          valid_locales += ::Releaf.available_admin_locales || []

          valid_locales.uniq.each do |locale|
            values[locale] = nil
          end

          translation_data.each do |value|
            values[value.lang] = value.localization if values.has_key? value.lang
          end

          values
        end

        def plain_key
          key.gsub(translation_group.scope + '.', '')
        end

        private

        def reassign_scope
          self.key = translation_group.scope + "." + key.split(".").last
        end
      end
    end
  end
end
