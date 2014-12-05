module Releaf::Content
  class MoveDialogBuilder
    include Releaf::Content::Builders::ActionDialog

    def action
      :move
    end
  end
end
