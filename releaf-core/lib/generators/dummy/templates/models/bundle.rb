class Bundle < ActiveRecord::Base
  acts_as_node

  # This model was created especially to test a specific bug, that was
  # discovered with such classes as this.
  # It turns out that Node didn't create content object because no field of
  # placeholder model was rendered in form, thus no attribute of content object
  # was submitted.
  #
  # This class was added to test this bug, and to prevent regressions.
  #
  # Real life scenario:
  #   At the moment of impllementing system, programmer knew he will need to
  #   create bundles, however details about this funcionality wasn't fully clear.
  #   Thus he created placeholder model.
  #
end
