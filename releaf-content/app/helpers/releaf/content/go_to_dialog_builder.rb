module Releaf::Content
  class GoToDialogBuilder
    include Releaf::Content::Builders::Dialog

    def section_header_text
      t("Go to node")
    end
  end
end
