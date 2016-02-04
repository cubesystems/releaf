module Releaf::ActionController::Urls
  extend ActiveSupport::Concern

  included do
    helper_method :current_url, :index_url
  end

  # Returns url to redirect after successul resource create/update actions
  #
  # @return [String] url
  def success_url
    if create_another?
      url_for(action: 'new')
    else
      url_for(action: 'edit', id: @resource.id, index_url: index_url)
    end
  end

  # Returns index url for current request
  #
  # @return String
  def index_url
    if @index_url.nil?
      # use current url
      if action_name == "index"
        @index_url = current_url
      # use from get params
      elsif params[:index_url].present?
        @index_url = params[:index_url]
      # fallback to index view
      else
        @index_url = url_for(action: 'index')
      end
    end

    @index_url
  end

  # Returns current url without internal params
  #
  # @return String
  def current_url
    @current_url ||= [request.path, (request.query_parameters.to_query if request.query_parameters.present?)].compact.join("?")
  end
end
