module Releaf::ActionController::Ajax
  extend ActiveSupport::Concern

  included do
    helper_method :ajax?
    before_action :manage_ajax
  end

  def ajax?
    @_ajax || false
  end

  def layout
    ajax? ? false : "releaf/admin"
  end

  def manage_ajax
    @_ajax = params.has_key? :ajax
    if @_ajax
      request.query_parameters.delete(:ajax)
      params.delete(:ajax)
    end
  end
end
