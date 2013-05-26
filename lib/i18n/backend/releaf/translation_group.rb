require 'active_record'

module I18n
  module Backend
    class Releaf
      class TranslationGroup < ::ActiveRecord::Base

        self.table_name = "releaf_translation_groups"

        validates_presence_of :scope
        validates_uniqueness_of :scope

        has_many :translations, :dependent => :destroy, :foreign_key => :group_id, :order => 'releaf_translations.key'

        attr_accessible \
          :scope

        def to_s
          scope
        end

      end
    end
  end
end

