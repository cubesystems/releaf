class ApplicationController < ActionController::Base
  class PageNotFound < StandardError; end
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  protect_from_forgery with: :exception
  before_action :set_locale
  layout "application"
  helper_method :translation_scope, :node_class, :site

  def render_404
    render file: Rails.root.join('public', '404.html'), status: 404, layout: nil
  end

  def set_locale
    I18n.locale = params[:locale]
  end

  def redirect_to_locale_root
    # if no matching root found for any of client locales
    # use first root
    target_root = available_roots.first
    if target_root
      redirect_to target_root.path
    else
      render text: "Welcome to Releaf", layout: true
    end
  end

  def translation_scope
    "public." + self.class.name.gsub("Controller", "").underscore
  end

  def node_class
    if @node_class.blank?
      # this method detects whether the dummy application is running in a single or multiple node context
      routing = Releaf::Content.routing

      if routing.length == 1
        # for single node class site
        # the node class is the first and only defined class
        node_class = routing.keys.first.constantize
      else
        # for multinode sites
        # for non-node routes the node class can be detected from hostname via routing config
        node_class = Releaf::Content.routing.find { |node_class_name, options| request.host =~ options[:constraints][:host] }.first.constantize
      end
      @node_class = node_class
    end
    @node_class
  end

  def site
    # for non-node routes site is detectable from node class via routing config
    @site = Releaf::Content.routing[node_class.name][:site]
  end

  def available_roots
    @roots ||= node_class.roots.where(locale: I18n.available_locales, active: true)
  end
end
