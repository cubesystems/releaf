class Releaf::ResourceTableFields < Releaf::ResourceFields

  def excluded_attributes
    super + table_excluded_attributes
  end

  def table_excluded_attributes
    (base_attributes + localized_attributes).select{|c| c.match(/.*(_uid|_html)$/) }
  end
end
