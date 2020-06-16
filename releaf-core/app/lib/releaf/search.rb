module Releaf
  class Search
    attr_accessor :relation, :fields, :text, :join_index, :searchable_arel_fields

    delegate :base_class, to: :relation

    def self.prepare(relation:, fields:, text:)
      searcher = new(relation: relation, fields: fields, text: text)
      searcher.prepare
      searcher.relation
    end

    def initialize(relation: , fields:, text:)
      self.relation = relation.all
      self.fields = fields
      self.text = text
    end

    def prepare
      self.join_index = 0
      self.searchable_arel_fields = []

      join_search_tables(base_class)
      add_search_to_relation
    end

    private

    def join_search_tables klass, attributes: fields, table: klass.arel_table
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

    def add_search_to_relation
      text.strip.split(" ").each do |word|
        query = searchable_arel_fields.map do |field|
          field.matches(Arel::Nodes::Quoted.new("%#{word}%"))
        end.inject { |result, query_part| result.or(query_part) }

        self.relation = relation.where(query)
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
                       when :has_many
                         self.relation = relation.distinct
                         table1[primary_key].eq(table2[foreign_key])
                       when :has_one
                         table1[primary_key].eq(table2[foreign_key])
                       when :belongs_to
                         table1[foreign_key].eq(table2[primary_key])
                       else
                         raise 'not implemented'
                       end

      if reflection.type
        polymorphic_type_condition = table2[reflection.type.to_sym].eq(klass.base_class.name)
        join_condition = join_condition.and(polymorphic_type_condition)
      end

      if reflection.scope
        where_scope = extract_where_condition_from_scope(reflection, table2_alias)
        join_condition = join_condition.and(where_scope) if where_scope.present?
      end

      if other_class.ancestors.include?(Globalize::ActiveRecord::Translation)
        # only search in current locale
        join_condition = join_condition.and(table2[:locale].eq(I18n.locale.to_s))
      end

      self.relation = relation.joins(arel_join(table1, table2, join_condition))
      table2
    end

    def extract_where_condition_from_scope(reflection, table_alias)
      tmp_relation = build_tmp_relation(reflection, table_alias)

      return nil if tmp_relation.where_values_hash.blank?

      tmp_relation.arel.ast.cores.first.wheres
    end

    def build_tmp_relation(reflection, table_alias)
      # Need to create tmp relation since setting table alias for actual klass
      # is a bad idea.
      klass = Class.new(reflection.klass) do
        self.arel_table.table_alias = table_alias
      end

      klass.instance_exec(&reflection.scope)
    end

    def join_reflection_with_through(reflection, table)
      joined_table = join_reflection_without_through(reflection.through_reflection, table)
      join_reflection_without_through(reflection.source_reflection, joined_table)
    end

    def arel_join(table1, table2, join_condition, join_type: Arel::Nodes::OuterJoin)
      on_condition = table1.create_on(join_condition)
      table1.create_join(table2, on_condition, join_type)
    end
  end
end
