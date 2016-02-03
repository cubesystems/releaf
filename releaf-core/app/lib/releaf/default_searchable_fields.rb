module Releaf
  class DefaultSearchableFields
    attr_accessor :klass

    def initialize(klass)
      self.klass = klass
    end

    def find
      search_columns = possible_field_names & string_columns
      search_columns << { translations: searchable_translated_string_columns } if has_searchable_translated_string_columns?
      search_columns
    end

    def string_columns
      klass.columns.select { |column| column.type == :string }.map(&:name)
    end

    def searchable_translated_string_columns
      @searchable_translated_string_columns ||= self.class.new(klass::Translation).find
    end

    def has_searchable_translated_string_columns?
      return false unless klass.translates?
      searchable_translated_string_columns.present?
    end

    def possible_field_names
      %w[
        email
        first_name
        forename
        last_name
        login
        middle_name
        name
        surname
        title
        username
      ]
    end
  end
end
