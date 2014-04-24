module Releaf
  module ReleafDeviseHelper
    # FIXME need better name
    def self.devise_admin_model_name
      Releaf.devise_for.underscore.tr('/', '_')
    end
  end
end
