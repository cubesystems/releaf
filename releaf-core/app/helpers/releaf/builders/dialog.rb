module Releaf::Builders::Dialog

  def output
    tag(:section, class: classes) do
      section_blocks
    end
  end

  def classes
    ["dialog", self.class.name.split("::").last.gsub(/DialogBuilder$/, "").underscore.dasherize]
  end

end
