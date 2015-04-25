module Admin::Books
  class TableBuilder < Releaf::Builders::TableBuilder
    def column_names
      super + ["author.publisher.title"]
    end
  end
end
