class ApplicationController < ActionController::Base
  class PageNotFound < StandardError; end
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  protect_from_forgery with: :exception
  before_filter :set_locale
  layout "application"
  helper_method :translation_scope

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
      redirect_to target_root.url
    else
      render text: "Welcome to re:Leaf", layout: true
    end
  end

  def translation_scope
    "public." + self.class.name.gsub("Controller", "").underscore
  end

  private

  def available_roots
    @roots ||= Node.roots.where(locale: I18n.available_locales, active: true)
  end
end
