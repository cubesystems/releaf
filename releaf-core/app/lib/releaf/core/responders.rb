module Releaf::Core::Responders

  def respond_with(resource = nil, options = {}, &block)
    options[:responder] = active_responder unless options.has_key? :responder
    super
  end

  def action_responders
    {
      create: Releaf::Core::Responders::AfterSaveResponder,
      update: Releaf::Core::Responders::AfterSaveResponder,
      confirm_destroy: Releaf::Core::Responders::ConfirmDestroyResponder,
      destroy: Releaf::Core::Responders::DestroyResponder,
      access_denied: Releaf::Core::Responders::AccessDeniedResponder,
      feature_disabled: Releaf::Core::Responders::FeatureDisabledResponder,
      page_not_found: Releaf::Core::Responders::PageNotFoundResponder,
    }
  end

  # Returns generic view name for given action
  # @return String
  def action_responder(_action_name)
    action_responders[_action_name.to_sym]
  end

  # Returns generic view name for current action
  # @return String
  def active_responder
    action_responder(action_name)
  end
end
