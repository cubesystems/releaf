class Admin::BookFormBuilder < Releaf::Builders::FormBuilder
  def field_names
    super + [{chapters: %w[title text sample_html]}]
  end
end
