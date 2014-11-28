class Admin::BookFormBuilder < Releaf::FormBuilder
  def field_names
    super + [{chapters: %w[title text sample_html]}]
  end
end
