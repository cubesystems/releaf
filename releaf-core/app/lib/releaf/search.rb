# TODO convert to arel
module Releaf
  class Search
    attr_accessor :relation, :fields, :text

    delegate :base_class, to: :relation

    def self.prepare(relation: , fields:, text:)
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
      add_includes_to_relation
      add_search_to_relation
    end

    private

    def add_search_to_relation
      fields_to_search = normalize_fields(base_class, fields)
      text.strip.split(" ").each_with_index do |word, i|
        query = fields_to_search.map { |field| "LOWER(#{field}) LIKE LOWER(:word#{i})" }.join(' OR ')
        self.relation = relation.where(query, "word#{i}".to_sym =>'%' + word + '%')
      end
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

    def normalize_fields_hash klass, hash_attribute
      fields = []

      hash_attribute.each_pair do |association_name, association_attributes|
        association = klass.reflect_on_association(association_name.to_sym)
        fields += normalize_fields(association.klass, association_attributes)
        if association.macro == :has_many
          self.relation = relation.uniq
        end
      end

      fields
    end

    # Returns data structure for .includes or .joins that represents resource
    # associations, beased on given structure of attributes
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

    def add_includes_to_relation
      joins_list = normalized_joins( joins(base_class, fields) )

      unless joins_list.empty?
        self.relation = relation.includes(*joins_list).references(*join_references(joins_list))
      end
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

  end
end
