class Admin::AuthorsController < Releaf::BaseController
  protected

  def setup
    super
    @searchable_fields = [:name, :surname, books: [:title, chapters: [:title]]]
    @resources_per_page = params.has_key?(:show_all) ? nil : 20
  end
end
