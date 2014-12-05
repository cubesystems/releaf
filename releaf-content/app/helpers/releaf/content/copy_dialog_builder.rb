module Releaf::Content
  class CopyDialogBuilder
    include Releaf::Content::Builders::ActionDialog

    def action
      :copy
    end
  end
end
