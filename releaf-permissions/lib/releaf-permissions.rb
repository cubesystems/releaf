require 'devise'
require 'releaf/permissions/engine'

module Releaf::Permissions
  extend ActiveSupport::Concern

  included do
    before_filter :authenticate!, :verify_controller_access!, :set_locale
  end

  # set locale for interface translating from current admin user
  def set_locale
    I18n.locale = access_control.user.locale
  end

  def layout_settings(key)
    access_control.user.try(:settings).try(:[], key)
  end

  def authenticate!
    access_control.authenticate!
  end

  def verify_controller_access!
    unless access_control.controller_allowed?(access_control.current_controller_name)
      raise Releaf::Core::AccessDenied.new(access_control.current_controller_name)
    end
  end

  def access_control
    @access_control ||= Releaf::Permissions::AccessControl.new(controller: self)
  end
end
