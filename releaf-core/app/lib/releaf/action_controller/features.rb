module Releaf::ActionController::Features
  extend ActiveSupport::Concern

  included do
    before_action :verify_feature_availability!
    helper_method :feature_available?
    rescue_from Releaf::FeatureDisabled, with: :feature_disabled
  end

  def verify_feature_availability!
    feature = action_feature(params[:action])
    raise Releaf::FeatureDisabled, feature.to_s if feature.present? && !feature_available?(feature)
  end

  def action_feature(action)
    action_features[action.to_sym]
  end

  def features
    [:edit, :create, :create_another, :destroy, :index, :toolbox, :search]
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
    }
  end

  def feature_disabled(exception)
    @feature = exception.message
    respond_with(nil, responder: action_responder(:feature_disabled))
  end

  def feature_available?(feature)
    return false if feature.blank?
    return false if feature == :create_another && !feature_available?(:create)
    return false if feature == :search && !feature_available?(:index)
    features.include? feature
  end
end
