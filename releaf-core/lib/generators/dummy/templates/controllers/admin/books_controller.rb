class Admin::BooksController < Releaf::BaseController
  def setup
    super
    @searchable_fields = [:title]
  end

  def permitted_params
    super + [{chapters_attributes: [:title, :text, :sample_html, :id, :_destroy, :item_position]}]
  end
end

