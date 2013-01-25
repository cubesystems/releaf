module Leaf
  class BaseApplicationController < ActionController::Base
    # include LeafDeviseHelper

    before_filter "authenticate_#{LeafDeviseHelper.devise_admin_model_name}!"
    # check_authorization :unless => :devise_controller?
    layout Leaf.layout
    protect_from_forgery

    def current_ability
      @current_ability ||= AdminAbility.new(self.send("current_#{LeafDeviseHelper.devise_admin_model_name}"))
    end

  end
end
