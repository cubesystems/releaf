class Admin::AuthorsController < Releaf::ActionController
  def searchable_fields
    [:name, :surname, books: [:title, chapters: [:title]]]
  end

  def resources_per_page
    params.has_key?(:show_all) ? nil : 20
  end
end
