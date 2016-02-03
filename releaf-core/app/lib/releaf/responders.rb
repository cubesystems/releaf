module Releaf::Responders

  def respond_with(resource = nil, options = {}, &block)
    options[:responder] = active_responder unless options.has_key? :responder
    super
  end

  def action_responders
    {
      create: Releaf::Responders::AfterSaveResponder,
      update: Releaf::Responders::AfterSaveResponder,
      confirm_destroy: Releaf::Responders::ConfirmDestroyResponder,
      destroy: Releaf::Responders::DestroyResponder,
      access_denied: Releaf::Responders::AccessDeniedResponder,
      feature_disabled: Releaf::Responders::FeatureDisabledResponder,
      page_not_found: Releaf::Responders::PageNotFoundResponder,
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
