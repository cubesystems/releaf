module Releaf::Builders::Dialog

  def output
    tag(:section, class: classes) do
      section_blocks
    end
  end

  def classes
    ["dialog", dialog_name]
  end

  def dialog_name
    self.class.name.split("::").last.gsub(/DialogBuilder$/, "").underscore.dasherize
  end

  def section_footer_class
    nil
  end

end
