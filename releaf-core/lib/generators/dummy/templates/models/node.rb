class Node < ActiveRecord::Base
  include Releaf::Content::Node
  validates_with Releaf::Content::Node::RootValidator, allow: [HomePage]
  validates_with Releaf::Content::Node::ParentValidator, for: [ContactsController], under: HomePage
  validates_with Releaf::Content::Node::SinglenessValidator, for: [ContactsController], under: HomePage

  def locale_selection_enabled?
    root?
  end
end
