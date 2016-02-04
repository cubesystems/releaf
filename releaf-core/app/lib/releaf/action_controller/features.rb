module Releaf::ActionController::Features
  extend ActiveSupport::Concern

  included do
    before_filter :verify_feature_availability!
    helper_method :feature_available?
    rescue_from Releaf::FeatureDisabled, with: :feature_disabled
  end

  def verify_feature_availability!
    feature = action_feature(params[:action])
    raise Releaf::FeatureDisabled, feature.to_s if (feature.present? && !feature_available?(feature))
  end

  def action_feature action
    action_features[action]
  end

  # == Defines
  # features::
  #   Array with symbol keys. If one
  #   of features is disabled, then routing to it will raise <tt>Releaf::FeatureDisabled</tt>
  #   error
  def features
    [:edit, :create, :create_another, :destroy, :index, :toolbox]
  end

  def action_features
    {
      index: :index,
      new: :create,
      create: :create,
      show: (feature_available?(:show) ? :show : :edit),
      edit: :edit,
      update: :edit,
      confirm_destroy: :destroy,
      destroy: :destroy
    }.with_indifferent_access
  end

  def feature_disabled exception
    @feature = exception.message
    respond_with(nil, responder: action_responder(:feature_disabled))
  end

  def feature_available?(feature)
    return false if feature == :create_another && !feature_available?(:create)
    features.include? feature
  end
end
