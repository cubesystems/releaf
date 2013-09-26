class Admin::AuthorsController < Releaf::BaseController
  protected

  def setup
    super
    @searchable_fields = [:name, :surname, books: [:title, chapters: [:title]]]
  end
end
