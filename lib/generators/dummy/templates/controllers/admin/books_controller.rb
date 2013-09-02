class Admin::BooksController < Releaf::BaseController
  def setup
    super
    @searchable_fields = [:title]
  end
end

