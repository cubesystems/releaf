module Releaf::ActionController::Notifications
  extend ActiveSupport::Concern

  # Tries to return resource class.
  #
  # If it fails to return proper resource class for your controller, or your
  # controllers name has no relation to resource class name, then simply
  # override this method to return class that you want.
  #
  def render_notification(status, success_message_key: "#{params[:action]} succeeded", failure_message_key: "#{params[:action]} failed", now: false)
    if now == true
      flash_target = flash.now
    else
      flash_target = flash
    end

    if status
      flash_target["success"] = { "id" => "resource_status", "message" => I18n.t(success_message_key, scope: notice_scope_name) }
    else
      flash_target["error"] = { "id" => "resource_status", "message" => I18n.t(failure_message_key, scope: notice_scope_name) }
    end
  end

  # Returns notice scope name
  def notice_scope_name
    'notices.' + controller_scope_name
  end
end
