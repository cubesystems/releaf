class Admin::BooksController < Releaf::BaseController
  def resources
    collection = super
    collection = collection.where(active: true) if params[:only_active]
    collection
  end
end
