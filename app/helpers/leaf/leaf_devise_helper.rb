module Leaf
  module LeafDeviseHelper
    # FIXME need better name
    def self.devise_admin_model_name
      Leaf.devise_for.underscore.tr('/', '_')
    end
  end
end
