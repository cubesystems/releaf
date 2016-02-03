class Admin::AuthorsController < Releaf::BaseController
  def searchable_fields
    [:name, :surname, books: [:title, chapters: [:title]]]
  end

  protected

  def setup
    super
    self.resources_per_page = params.has_key?(:show_all) ? nil : 20
  end
end
