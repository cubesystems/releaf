module Releaf::ActionController::Views
  extend ActiveSupport::Concern

  included do
    helper_method :active_view
  end

  # Returns action > view translation hash
  # @return Hash
  def action_views
    {
      new: :edit,
      update: :edit,
      create: :edit,
    }
  end

  # Returns generic view name for given action
  # @return String
  def action_view(_action_name)
    action_views[_action_name.to_sym] || _action_name
  end

  # Returns generic view name for current action
  # @return String
  def active_view
    action_view(action_name)
  end
end
