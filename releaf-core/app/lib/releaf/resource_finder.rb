module Releaf
  class ResourceFinder
    attr_accessor :resource_class, :collection, :searchable_fields, :searchable_arel_fields, :join_index

    def initialize resource_class
      self.resource_class = resource_class
    end

    # Get resources collection for #index
    def search text, searchable_fields, base_collection = resource_class.all
      self.collection = base_collection.dup
      self.searchable_fields = searchable_fields
      self.join_index = 0
      self.searchable_arel_fields = []

      join_search_tables(resource_class)
      add_search_to_collection(text)

      collection
    end

    private

    def join_search_tables klass, attributes: searchable_fields, table: klass.arel_table
      attributes.each do |attribute|
        if attribute.is_a? Hash
          attribute.each_pair do |key, values|
            reflection = klass.reflect_on_association(key.to_sym)
            joined_table = join_reflection(reflection, table)
            join_search_tables(reflection.klass, attributes: values, table: joined_table)
          end
        elsif attribute.is_a?(Symbol) || attribute.is_a?(String)
          self.searchable_arel_fields << table[attribute]
        else
          raise 'not implemented'
        end
      end
    end

    def add_search_to_collection(text)
      text.strip.split(" ").each do |word|
        query = searchable_arel_fields.map do |field|
          lower_field = Arel::Nodes::NamedFunction.new('LOWER', [field])
          ActiveRecord::Base.send(:sanitize_sql_array, ["(#{lower_field.to_sql} LIKE LOWER(:word))", word: "%#{word}%"])
        end.join(' OR ')
        self.collection = collection.where(query)
      end
    end

    def join_reflection(reflection, table)
      if reflection.options[:through]
        join_reflection_with_through(reflection, table)
      else
        join_reflection_without_through(reflection, table)
      end
    end

    def join_reflection_without_through(reflection, table)
      klass = reflection.active_record
      other_class = reflection.klass

      table1 = table || klass.arel_table
      table2_alias = "#{other_class.arel_table.name}_f#{join_index}"
      table2 = other_class.arel_table.alias(table2_alias)
      self.join_index += 1

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
        tmp_class = Class.new(other_class) do
          self.arel_table.table_alias = table2_alias
        end

        where_scope = tmp_class.instance_exec(&reflection.scope).where_values
        join_condition = join_condition.and(where_scope)
      end

      self.collection = collection.joins(arel_join(table1, table2, join_condition))
      table2
    end

    def join_reflection_with_through(reflection, table)
      joined_table = join_reflection_without_through(reflection.through_reflection, table)
      join_reflection_without_through(reflection.source_reflection, joined_table)
    end

    def arel_join(table1, table2, join_condition, join_type: Arel::Nodes::OuterJoin)
      source_table = if table1.is_a?(Arel::Nodes::TableAlias)
                       table = table1.left.dup
                       table.table_alias = table1.table_alias
                       table
                     else
                       table1
                     end
      source_table.join(table2, join_type).on(join_condition).join_sources
    end
  end
end
