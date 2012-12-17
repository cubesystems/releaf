module LeafRails
  class ApplicationController < ActionController::Base
    before_filter :authenticate_admin!
    check_authorization :unless => :devise_controller?

    def current_ability
      @current_ability ||= AdminAbility.new(current_admin)
    end
  end
end
