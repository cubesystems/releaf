module Releaf::Builders::Resource
  attr_accessor :resource

  def initialize(template)
    super
    self.resource = template_variable("resource")
  end

end
