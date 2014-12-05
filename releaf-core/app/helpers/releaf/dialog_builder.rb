module Releaf::DialogBuilder
  include Releaf::ViewBuilder
  attr_accessor :resource

  def initialize(template)
    super
    self.resource = template.instance_variable_get("@resource")
  end

  def output
    tag(:section, class: classes) do
      section_blocks
    end
  end

  def classes
    ["dialog", self.class.name.split("::").last.gsub(/DialogBuilder$/, "").underscore.dasherize]
  end
end
