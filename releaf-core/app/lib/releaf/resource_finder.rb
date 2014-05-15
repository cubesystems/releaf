module Releaf
  module ResourceFinder

    module ActionController
      def search text
        return unless @searchable_fields && params[:search].present?
        @collection = Releaf::ResourceFinder.search(resource_class, @searchable_fields, text, @collection)
      end
    end

    # Get resources collection for #index
    def self.search resource_class, searchable_fields, text, collection=resource_class.all
      fields, collection = search_fields(collection, resource_class, searchable_fields)
      s_joins = normalized_search_joins( search_joins(resource_class, searchable_fields) )
      unless s_joins.empty?
        collection = collection.includes(*s_joins).references(*references_for_includes(s_joins))
      end
      text.strip.split(" ").each_with_index do|word, i|
        query = fields.map { |field| "#{field} LIKE :word#{i}" }.join(' OR ')
        collection = collection.where(query, "word#{i}".to_sym =>'%' + word + '%')
      end

      return collection
    end

    private

    # Returns array of fields in which to search for string typed in search form
    def self.search_fields collection, klass, attributes
      fields = []
      attributes.each do|attribute|
        if attribute.is_a?(Symbol) || attribute.is_a?(String)
          fields << "#{klass.table_name}.#{attribute.to_s}"
        elsif attribute.is_a? Hash
          attribute.each_pair do |key, values|
            association = klass.reflect_on_association(key.to_sym)
            more_fields, collection = search_fields(collection, association.klass, values)
            fields += more_fields
            if association.macro == :has_many
              collection = collection.group("#{association.klass.table_name}.id")
            end
          end
        end
      end

      return [fields, collection]
    end

    # Returns data structure for .includes or .joins that represents resource
    # associations, beased on given structure of attributes
    #
    # This helper is mainly intended for #search
    def self.search_joins klass, attributes
      s_joins = {}
      attributes.each do|attribute|
        if attribute.is_a? Hash
          attribute.each_pair do |key, values|
            association = klass.reflect_on_association(key.to_sym)
            s_joins[key] = s_joins.fetch(key, {}).deep_merge( search_joins(association.klass, values) )
          end
        end
      end

      return s_joins
    end

    # Normalizes #search_joins results by removing blank hashes
    def self.normalized_search_joins search_joins
      raise ArgumentError unless search_joins.is_a? Hash
      assoc = []
      search_joins.each_pair do |k, v|
        if v.blank?
          assoc.push k
        else
          normalized_v = normalized_search_joins v
          if normalized_v.blank?
            assoc.push k
          else
            assoc.push({k => normalized_v})
          end
        end
      end
      return assoc
    end

    # get params for references, given structure that is used for includes
    def self.references_for_includes includes
      normalized = []
      if includes.is_a? Hash
        normalized.push references_for_includes(includes.to_a)
      elsif includes.is_a? Array
        includes.each do |incl|
          if incl.is_a?(Array) || incl.is_a?(Hash)
            normalized.push references_for_includes(incl.to_a)
          else
            normalized.push incl
          end
        end
      else
        normalized.push includes
      end
      return normalized.flatten.uniq
    end

  end
end
