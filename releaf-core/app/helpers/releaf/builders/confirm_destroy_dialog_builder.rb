class Releaf::Builders::ConfirmDestroyDialogBuilder < Releaf::Builders::ConfirmDialogBuilder
  def question_content
    t('Do you want to destroy following object?', scope: 'admin.global')
  end

  def description_content
    resource_to_text(resource)
  end

  def section_header_text
    t('Confirm destroy', scope: 'admin.global')
  end

  def icon
    "trash-o"
  end

  def confirm_url
    url_for( action: 'destroy', id: resource.id, index_url: index_url)
  end
end
