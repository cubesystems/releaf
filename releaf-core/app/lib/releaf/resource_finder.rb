# TODO convert to arel
module Releaf
  class ResourceFinder
    attr_accessor :resource_class, :collection, :searchable_fields

    def initialize resource_class
      self.resource_class = resource_class
    end

    # Get resources collection for #index
    def search text, searchable_fields, base_collection = resource_class.all
      self.collection = base_collection
      self.searchable_fields = searchable_fields

      add_includes_to_collection
      add_search_to_collection(text)

      collection
    end

    # Returns array of fields in which to search for string typed in search form
    def normalize_fields klass, attributes
      fields = []

      attributes.each do |attribute|
        if attribute.is_a?(Symbol) || attribute.is_a?(String)
          fields << "#{klass.table_name}.#{attribute.to_s}"
        elsif attribute.is_a? Hash
          fields += normalize_fields_hash(klass, attribute)
        end
      end

      fields
    end

    # Returns data structure for .includes or .joins that represents resource
    # associations, beased on given structure of attributes
    #
    # This helper is mainly intended for #search
    def joins klass, attributes
      join_list = {}

      attributes.each do |attribute|
        if attribute.is_a? Hash
          attribute.each_pair do |key, values|
            association = klass.reflect_on_association(key.to_sym)
            join_list[key] = join_list.fetch(key, {}).deep_merge( joins(association.klass, values) )
          end
        end
      end

      join_list
    end

    # Normalizes joins results by removing blank hashes
    def normalized_joins denormalized_joins
      associations = []

      denormalized_joins.each_pair do |join, sub_joins|
        if sub_joins.blank?
          associations << join
        else
          associations << {join => normalized_joins(sub_joins)}
        end
      end

      associations
    end

    # get params for references, given structure that is used for includes
    def join_references denormalized_includes
      includes = []

      denormalized_includes.each do |incl|
        if incl.is_a?(Array) || incl.is_a?(Hash)
          includes << join_references(incl.to_a)
        else
          includes << incl
        end
      end

      includes.flatten.uniq
    end

    private

    def normalize_fields_hash klass, hash_attribute
      fields = []

      hash_attribute.each_pair do |association_name, association_attributes|
        association = klass.reflect_on_association(association_name.to_sym)
        fields += normalize_fields(association.klass, association_attributes)
        if association.macro == :has_many
          self.collection = collection.uniq
        end
      end

      fields
    end

    def add_search_to_collection(text)
      fields = normalize_fields(resource_class, searchable_fields)
      text.strip.split(" ").each_with_index do |word, i|
        query = fields.map { |field| "LOWER(#{field}) LIKE LOWER(:word#{i})" }.join(' OR ')
        self.collection = collection.where(query, "word#{i}".to_sym =>'%' + word + '%')
      end
    end

    def add_includes_to_collection
      joins_list = normalized_joins( joins(resource_class, searchable_fields) )

      unless joins_list.empty?
        self.collection = collection.includes(*joins_list).references(*join_references(joins_list))
      end
    end
  end
end
