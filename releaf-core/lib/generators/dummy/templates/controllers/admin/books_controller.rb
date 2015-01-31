class Admin::BooksController < Releaf::BaseController
    include Releaf::RichtextAttachments::ActionController
  def setup
    super
    @searchable_fields = [:title]
  end
end
