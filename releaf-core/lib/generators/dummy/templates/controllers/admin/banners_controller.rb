class Admin::BannersController < Releaf::ActionController
  def features
    [:index, :show]
  end
end
