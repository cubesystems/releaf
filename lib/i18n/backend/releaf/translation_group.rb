require 'active_record'

module I18n
  module Backend
    class Releaf
      class TranslationGroup < ::ActiveRecord::Base

        self.table_name = "releaf_translation_groups"

        validates_presence_of :scope

        has_many :translations, :dependent => :destroy, :foreign_key => :group_id, :order => 'releaf_translations.key'
        after_commit :reload_cache

        def to_s
          scope
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

