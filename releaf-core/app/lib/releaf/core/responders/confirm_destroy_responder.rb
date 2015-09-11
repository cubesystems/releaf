module Releaf::Core::Responders
  class ConfirmDestroyResponder < ActionController::Responder
    delegate :render_notification, to: :controller

    def to_html
      if options[:destroyable]
        super
      else
        render 'refused_destroy'
      end
    end
  end
end
