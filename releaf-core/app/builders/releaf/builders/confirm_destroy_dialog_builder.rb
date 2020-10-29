class Releaf::Builders::ConfirmDestroyDialogBuilder < Releaf::Builders::ConfirmDialogBuilder
  def question_content
    t("Do you want to delete the following object?")
  end

  def description_content
    resource_title(resource)
  end

  def section_header_text
    t("Confirm deletion")
  end

  def confirm_method
    :delete
  end

  def icon_name
    "trash-o"
  end

  def confirm_url
    url_for( action: 'destroy', id: resource.id, index_path: index_path)
  end
end
