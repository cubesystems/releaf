class OtherSite::OtherNode < ActiveRecord::Base
  include Releaf::Content::Node

  def locale_selection_enabled?
    root?
  end
end
