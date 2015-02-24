module Releaf::Builders::Collection
  attr_accessor :collection

  def initialize(template)
    super
    self.collection = template_variable("collection")
  end
end
