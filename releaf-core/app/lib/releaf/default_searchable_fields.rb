module Releaf
  class DefaultSearchableFields
    attr_accessor :klass

    def initialize(klass)
      self.klass = klass
    end

    def find
      possible_field_names & string_columns
    end

    def string_columns
      klass.columns.select { |column| column.type == :string }.map(&:name)
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
