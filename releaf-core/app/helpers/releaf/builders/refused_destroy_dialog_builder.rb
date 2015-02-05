class Releaf::Builders::RefusedDestroyDialogBuilder
  include Releaf::Builders::View
  include Releaf::Builders::ResourceDialog

  def section_body
    tag(:div, class: "body") do
      [
        icon("ban"),
        tag(:div, t("Deletion of %{resource} restricted, due to existing relations:", scope: "admin.global", default: "Deletion of %{resource} restricted, due to existing relations:", resource: resource_to_text(resource)), class: "description"),
        restricted_relations
      ]
    end
  end

  def restricted_relations
    tag(:ul, class: "block restricted-relations") do
      template_variable("restrict_relations").collect do|key, relation|
        tag(:li) do
          restricted_relation(relation, key)
        end
      end
    end
  end

  def relation_description(relation, key)
      (
        unless relation[:controller].nil?
          I18n.t(relation[:controller], scope: 'admin.controllers')
        else
          I18n.t(key, scope: 'admin.controllers')
        end
      ) << " (#{relation[:objects].count})"
  end

  def relation_objects(relation)
    tag(:ul, class: "block relations") do
      relation[:objects][0..2].collect do |relation_obj|
        tag(:li) do
          unless relation[:controller].nil?
            link_to(resource_to_text(relation_obj), controller: relation[:controller], action: "edit", id: relation_obj)
          else
            resource_to_text(relation_obj)
          end
        end
      end + [(tag(:li, "...") if relation[:objects].count > 3)]
    end
  end

  def restricted_relation(relation, key)
    [
      relation_description(relation, key),
      relation_objects(relation)
    ]
  end

  def footer_primary_tools
    [
      button(t('Ok', scope: 'admin.global'), "check", href: index_url, data: {type: 'cancel'})
    ]
  end

  def section_header_text
    t('Delete restricted', scope: 'admin.global')
  end
end
