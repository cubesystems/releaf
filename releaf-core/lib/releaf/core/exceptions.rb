module Releaf::Core
  # A general Releaf exception
  class Error < StandardError; end

  # This error is raised when a user isn't allowed to access a given controller action.
  # This usually happens within a call to ControllerAdditions#authorize! but can be
  # raised manually.
  #
  #   raise Releaf::AccessDenied.new("Not authorized!", AdminArticles, :read)
  #
  # The passed message, action, and subject are optional and can later be retrieved when
  # rescuing from the exception.
  #
  #   exception.message # => "Not authorized!"
  #   exception.action # => :read
  #   exception.subject # => Article
  #
  # If the message is not specified (or is nil) it will default to "You are not authorized
  # to access this page." This default can be overridden by setting default_message.
  #
  #   exception.default_message = "Default error message"
  #   exception.message # => "Default error message"
  #
  # See ControllerAdditions#authorized! for more information on rescuing from this exception
  # and customizing the message using I18n.
  class AccessDenied < Error
    attr_reader :action, :subject
    attr_writer :default_message

    def initialize(controller = nil, action = nil, message = nil)
      @message = message
      @controller = controller
      @action = action
      @default_message = I18n.t(:"unauthorized.default", :default => "You are not authorized to access this page.")
    end

  end
end
