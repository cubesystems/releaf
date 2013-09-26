class Admin::BooksController < Releaf::BaseController

  def fields_to_display
    if %w[show index].include? params[:action]
      super
    else
      super + [{chapters: %w[title text]}]
    end
  end

  def setup
    super
    @searchable_fields = [:title]
  end

  def resource_params
    super + [:chapters_attributes]
  end
end

