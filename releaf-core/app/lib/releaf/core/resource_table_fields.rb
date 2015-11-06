class Releaf::Core::ResourceTableFields < Releaf::Core::ResourceFields

  def excluded_attributes
    super + table_excluded_attributes
  end

  def table_excluded_attributes
    resource_class.column_names.select{|c| c.match(/.*_html$/) }
  end
end
