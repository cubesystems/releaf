---
title: Builders
weight: 6
---

## Builders
There are following builders available for customization:
* FormBuilder: form fields
* TableBuilder: index table
* EditBuilder: edit layout
* IndexBuilder: index layout
* ToolbarBuilder: toolbar content

## Creation
Builders are scoped by same logic as views.
For example to implement custom edit form builder for Admin::ClientsController use must create
`app/helpers/admin/clients/form_builder.rb` with following content:

```
module Admin::Clients
  class FormBuilder < Releaf::Builders::FormBuilder
    def field_names
      %w(name surname email)
    end
  end
end
```
