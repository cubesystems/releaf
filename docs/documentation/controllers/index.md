---
title: "Index action"
weight: 1000
permalink: "/documentation/controllers/index/"
---

# Working with Index action

By default, the Index action displays a table of all records of the related model using the model's default scope and showing 40 records per page.

* [Filtering and ordering resources](#resources)
* [Changing the number of items displayed per page](#pagination)
* [Changing the displayed table columns](#columns)

## Filtering and ordering resources {#resources}

When listing resources, Releaf uses the `.all` method of the model class by default.

The scope that gets used can be changed by overriding the `resources` method.

This is useful for specifying the order of records and performing eager loading of associations if the table will include some fields from associated models:

```ruby
class Admin::BooksController < Releaf::ActionController

  def resources
    resource_class.includes(:author).reorder(:title)
  end

end
```

This can also be used for applying conditional filtering:

```ruby
class Admin::BooksController < Releaf::ActionController

  def resources
    relation = super
    relation = relation.published if params[:only_published].present?
    relation
  end

end
```

Note that a text search feature is provided by Releaf, and there is no need to override the `resources` method just for that. See [Using search](../search/) for more on how it works.


## Changing the number of items displayed per page

To change the number of records shown per page, override the `resources_per_page` method:

```ruby
class Admin::BooksController < Releaf::ActionController

  def resources_per_page
    100
  end

end
```

If `resources_per_page` returns `nil`, no pagination will be performed.


## Changing the displayed table columns {#resources}

Customization of table columns in Index view is described in the [Customizing views chapter](../../builders/)

{% comment %} :TODO: link to the specific section of views chapter {% endcomment %}




