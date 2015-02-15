module Releaf::Responders
  class DestroyResponder < ActionController::Responder
    delegate :render_notification, to: :controller

    def to_html
      render_notification(@resource.destroyed?, failure_message_key: 'cant destroy, because relations exists')
      super
    end
  end
end
