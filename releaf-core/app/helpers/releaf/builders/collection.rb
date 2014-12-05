module Releaf::Builders::Collection
  attr_accessor :collection

  def initialize(template)
    super
    self.collection = template.instance_variable_get("@collection")
  end
end
