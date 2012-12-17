module LeafRails
  class ApplicationController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin'

    force_ssl
    protect_from_forgery
    #check_authorization :unless => :devise_controller?
    before_filter :filter_templates

    # def after_sign_in_path_for(resource_or_scope)
      # my_favorite_path
    # end

    def index
      # redirect_to auth_path
      # redirect_to "/status/"
    end

    private

    def current_ability
      @current_admin_ability ||= AdminAbility.new(current_admin)
    end

    def filter_templates
      filter_templates_from_hash params
    end

    def filter_templates_from_array arr
      return unless arr.is_a? Array
      arr.each do |item|
        if item.is_a? Hash
          filter_templates_from_hash item
        elsif item.is_a? Array
          filter_templates_from_array item
        end
      end
    end

    def filter_templates_from_hash hsk
      return unless hsk.is_a? Hash
      hsk.delete :_template_
      hsk.delete '_template_'

      filter_templates_from_array hsk.values
    end

  end

end
