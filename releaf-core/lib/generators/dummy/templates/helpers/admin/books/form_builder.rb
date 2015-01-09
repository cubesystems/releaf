module Admin::Books
  class FormBuilder < Releaf::Builders::FormBuilder
    def field_names
      super + [{chapters: %w[title text sample_html], book_sequels: %w[sequel_id]}]
    end

    def render_book_sequels_sequel_id
      releaf_item_field('sequel_id', options: { select_options: book_sequels_sequel_id_options })
    end

    def book_sequels_sequel_id_options
      original_book = options[:parent_builder].object
      books = Book.where(Book.arel_table[:id].not_eq(original_book.id))
      options_from_collection_for_select(books, :id, :to_text, object.sequel_id)
    end
  end
end
