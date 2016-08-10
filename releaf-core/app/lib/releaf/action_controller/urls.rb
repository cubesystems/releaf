module Releaf::ActionController::Urls
  extend ActiveSupport::Concern

  included do
    helper_method :current_path, :index_path
  end

  # Returns path to redirect after successul resource create/update actions
  #
  # @return [String] path
  def success_path
    if create_another?
      url_for(action: :new, only_path: true)
    else
      url_for(action: :edit, id: @resource.id, only_path: true, index_path: index_path)
    end
  end

  # Returns index path for current request
  #
  # @return [String] path
  def index_path
    @index_path ||= resolve_index_path
  end

  def resolve_index_path
    # use current url
    if action_name == "index"
      current_path
    # use from get params
    elsif valid_index_path?(params[:index_path])
      params[:index_path]
    # fallback to index view
    else
      url_for(action: :index, only_path: true)
    end
  end

  def valid_index_path?(value)
    value.present? && value.is_a?(String) && value.first == "/"
  end

  # Returns current path without internal params
  #
  # @return String
  def current_path
    @current_path ||= [request.path, (request.query_parameters.to_query if request.query_parameters.present?)].compact.join("?")
  end
end
