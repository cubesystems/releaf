module Releaf::Responders
  class AfterSaveResponder < ActionController::Responder
    delegate :render_notification, to: :controller

    def json_resource_errors
      {errors: Releaf::BuildErrorsHash.call(resource: resource, field_name_prefix: :resource)}
    end

    def to_json
      if has_errors?
        display_errors
      else
        redirect_to resource_location, status: 303, turbolinks: false
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
