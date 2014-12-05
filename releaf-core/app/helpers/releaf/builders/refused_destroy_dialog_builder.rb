class Releaf::RefusedDestroyDialogBuilder
  include Releaf::Builders::View
  include Releaf::Builders::ResourceDialog

  def section_body
    tag(:div, class: "body") do
      [
        template.fa_icon("ban"),
        tag(:div, t('Delete restricted', scope: 'admin.global'), class: "message"),
        tag(:div, t("Deletion of %{resource} restricted, due to existing relations:", scope: "admin.global", default: "Deletion of %{resource} restricted, due to existing relations:", resource: template.resource_to_text(resource)), class: "description"),
        restricted_relations
      ]
    end
  end

  def restricted_relations
    tag(:ul, class: "block restricted-relations") do
      template.instance_variable_get("@restrict_relations").collect do|key, relation|
        tag(:li) do
          restricted_relation(relation, key)
        end
      end
    end
  end

  def relation_description(relation, key)
      (
        unless relation[:controller].nil?
          I18n.t(relation[:controller], scope: 'admin.menu_items')
        else
          I18n.t(key, scope: 'admin.menu_items')
        end
      ) << " (#{relation[:objects].count})"
  end

  def relation_objects(relation)
    tag(:ul, class: "block relations") do
      relation[:objects][0..2].collect do |relation_obj|
        tag(:li) do
          unless relation[:controller].nil?
            template.link_to template.resource_to_text(relation_obj, :to_s), controller: relation[:controller], action: "edit", id: relation_obj
          else
            template.resource_to_text(relation_obj, :to_s)
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

  # TODO
  def section_header
  end
end
