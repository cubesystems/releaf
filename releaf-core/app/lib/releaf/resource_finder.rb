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
          fields << klass.arel_table[attribute.to_sym]
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
        query = fields.map do |field|
          lower_field = Arel::Nodes::NamedFunction.new('LOWER', [field])
          lower_query = Arel::Nodes::NamedFunction.new('LOWER', [Arel::Nodes::Quoted.new("%#{word}%")])
          lower_field.matches(lower_query)
        end.inject { |result, query_part| result.or(query_part) }
        self.collection = collection.where(query)
      end
    end

    def add_includes_to_collection
      joins_list = normalized_joins( joins(resource_class, searchable_fields) )

      if joins_list.present?
        self.collection = collection.joins(join_query(resource_class, *joins_list))
      end
    end

    def join_query klass, *joins_list
      joins_list.each do |item|
        if item.is_a? Hash
          item.each_pair do |association, sub_associations|
            join_query(klass, association)
            association_class = klass.reflect_on_association(association.to_sym).klass
            join_query(association_class, *sub_associations)
          end
        else
          association = item
          reflection = klass.reflect_on_association(association.to_sym)
          other_class = reflection.klass
          table1 = klass.arel_table
          table2 = other_class.arel_table
          foreign_key = reflection.foreign_key.to_sym
          primary_key = klass.primary_key.to_sym
          join_condition = case reflection.macro
                           when :has_many, :has_one
                             table1[primary_key].eq(table2[foreign_key])
                           when :belongs_to
                             table1[foreign_key].eq(table2[primary_key])
                           else
                             raise 'not implemented'
                           end
          arel_join(table1, table2, join_condition)
        end
      end
    end

    def arel_join(table1, table2, join_condition, join_type: Arel::Nodes::OuterJoin)
      table1.join(table2, join_type).on(join_condition).join_sources
    end
  end
end
