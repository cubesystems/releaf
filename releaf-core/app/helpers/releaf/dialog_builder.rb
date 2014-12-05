module Releaf::DialogBuilder
  include Releaf::SingleResourceBuilder

  def output
    tag(:section, class: classes) do
      section_blocks
    end
  end

  def classes
    ["dialog", self.class.name.split("::").last.gsub(/DialogBuilder$/, "").underscore.dasherize]
  end
end
