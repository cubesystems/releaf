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

      join_search_tables(resource_class, searchable_fields)
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

    private

    def join_search_tables klass, attributes
      attributes.each do |attribute|
        if attribute.is_a? Hash
          attribute.each_pair do |key, values|
            reflection = klass.reflect_on_association(key.to_sym)
            join_reflection(reflection)
            join_search_tables(reflection.klass, values)
          end
        end
      end
    end

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
      text.strip.split(" ").each do |word|
        query = fields.map do |field|
          lower_field = Arel::Nodes::NamedFunction.new('LOWER', [field])
          ActiveRecord::Base.send(:sanitize_sql_array, ["(#{lower_field.to_sql} LIKE LOWER(:word))", word: "%#{word}%"])
        end.join(' OR ')
        self.collection = collection.where(query)
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
          join_reflection(reflection)
        end
      end
    end

    def join_reflection(reflection)
      if reflection.options[:through]
        join_reflection_with_through(reflection)
      else
        join_reflection_without_through(reflection)
      end
    end

    def join_reflection_without_through(reflection, klass=reflection.active_record)
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

      if reflection.scope
        where_scope = other_class.instance_exec(&reflection.scope).where_values
        join_condition = join_condition.and(where_scope)
      end

      self.collection = collection.joins(arel_join(table1, table2, join_condition))
    end

    def join_reflection_with_through(reflection)
      # TODO refactor this method
      through_reflection = reflection.chain.last
      rightmost_reflection = through_reflection.klass.reflect_on_association(reflection.options[:source].to_sym)

      join_reflection_without_through(through_reflection)
      join_reflection_without_through(rightmost_reflection, through_reflection.klass)
    end

    def arel_join(table1, table2, join_condition, join_type: Arel::Nodes::OuterJoin)
      table1.join(table2, join_type).on(join_condition).join_sources
    end
  end
end
