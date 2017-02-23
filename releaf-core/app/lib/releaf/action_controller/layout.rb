module Releaf::ActionController::Layout
  extend ActiveSupport::Concern

  def layout_features
    [:header, :sidebar, :main]
  end
end
