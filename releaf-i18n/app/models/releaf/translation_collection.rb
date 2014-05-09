module Releaf
  class TranslationCollection
    attr_accessor :collection

    def initialize collection, valid=true
      @collection = collection
      @valid = valid
    end

    def valid?
      @valid
    end

    def self.update params
      collection = []
      deleted_items = []
      valid = true
      ActiveRecord::Base.transaction do
        params.each do |values|
          proxy = Releaf::TranslationProxy.new
          proxy.key = values['key']

          if values["_destroy"] == 'true'
            proxy.destroy
            deleted_items.push proxy
          else
            proxy.localizations = values["localizations"]
            unless proxy.save
              valid = false
            end

            collection.push proxy
          end
        end

        if valid
          Settings.i18n_updated_at = Time.now
        else
          collection += deleted_items
          raise ActiveRecord::Rollback
        end
      end

      self.new(collection, valid)
    end
  end
end
