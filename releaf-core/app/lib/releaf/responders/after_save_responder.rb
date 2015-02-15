module Releaf::Responders
  class AfterSaveResponder < ActionController::Responder
    delegate :render_notification, to: :controller

    def json_resource_errors
      {errors: Releaf::ErrorFormatter.format_errors(resource)}
    end

    def to_json
      if has_errors?
        display_errors
      elsif options[:redirect]
        render json: {url: resource_location}, status: 303
      else
        redirect_to resource_location, status: 303
      end
    end

    def respond
      render_notification(!has_errors?) if render_notification?
      super
    end

    def render_notification?
      !(format == :json && has_errors?)
    end
  end
end
