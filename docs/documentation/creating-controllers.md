---
title: Creating controllers
weight: 1300
---

# Creating controllers

Let's assume you have a `Book` model that you want to manage via Releaf:

```ruby
class Book < ActiveRecord::Base
  validates_presence_of :title
end
```

Creating a controller for it consists of the following steps:

1. [Create the controller](#controller)
2. [Add the controller to Releaf routes](#routes)
3. [Add the controller to Releaf navigation menu](#menu)
4. [Grant access to the controller to an administrator role](#permissions)
5. [Use the controller](#use)

## Create the controller {#controller}

Create an empty controller class that inherits from `Releaf::BaseController`.

Create a new file at

```
app/controllers/admin/books_controller.rb
```

with the following content:

```ruby
class Admin::BooksController < Releaf::BaseController; end
```

The `Admin` namespace is just an example and is not required, but it might be a good idea to keep your administrative controllers in a separate namespace if your application also has a public website side that may have its own `BooksController` for displaying the books to non-administrators.

## Add the controller to Releaf routes {#routes}

Add the controller to `routes.rb` inside the `mount_releaf_at` block.

```ruby
mount_releaf_at '/admin' do
  releaf_resources :books
end
```

This will generate all the default releaf routes for this controller, e.g. `admin_books`, `new_admin_book`, etc.

{% comment %} :TODO: link to a list of generated routes and their names {% endcomment %}

The `releaf_resources` helper accepts multiple arguments, so more controllers can be later added to the same line, e.g.:

```ruby
mount_releaf_at '/admin' do
  releaf_resources :books, :authors
end
```

Multiple calls to `releaf_resources` are also allowed:

```ruby
mount_releaf_at '/admin' do
  releaf_resources :books
  releaf_resources :authors
end
```

## Add the controller to Releaf navigation menu {#menu}

Open `config/initializers/releaf.rb` and add a new hash to the existing `config.menu` array:

```ruby
config.menu = [
  { controller: 'admin/books' }
  ...
]
```


This will create a top-level entry in the main Releaf menu in the sidebar.

The link text in the menu will be based on the controller name and run through `I18n.translate`, so it can be localized as needed.

If Releaf's I18n database backend component is used, the link text will be editable by administrators.
{% comment %} :TODO: link to I18n database chapter {% endcomment %}

Another, although rarely needed, way of changing the link text is by passing the `:name` option.

```ruby
config.menu = [
  { controller: 'admin/books', name: "publications" }
  ...
]
```

Related menu items can be grouped together in a category to avoid the menu becoming too long:

```ruby
config.menu = [
  {
    name: "library",
    items: %w[admin/books admin/authors],
  },
  ...
]
```
{% comment %} :TODO: can symbols be used for name? {% endcomment %}

Restart the Rails application after these changes.

## Grant access to the controller to an administrator role {#permissions}

If Releaf's default access control component is used, each administrator belongs to a role.

Each role can have access to a different set of controllers.

To add the permission to the new controller to a role:

1. Open Releaf in a browser by going to `/admin`.
2. Sign in as an administrator.
3. Open the roles menu item under "Permissions".
4. Select the needed role.
5. Tick the "Admin/books" checkbox.
6. Click the "Save" button at the bottom of the screen.

The sidebar menu should now have the newly added controller link visible.

{% comment %} :TODO: what about custom access control? can roles be disabled? what then? {% endcomment %}

## Use the controller {#use}

1. Click on the new item in the sidebar menu. An empty index view should open.
2. Click the "Create new resource" button at the bottom of the screen. A form should open with all the fields of the `Book` model editable.
3. Click the "Save" button.
4. If your model has any required attributes, the error messages should appear next to the empty required fields. Fill out the form and click "Save" again.
5. Go to the index view via menu or breadcrumbs at the top of the page. The table should now show your newly created record.

A built-in search is available at the top of the page. By default, it filters records by matching the entered text against all text attributes of the model.

{% comment %} :TODO: link to instructions about customizing search {% endcomment %}

To delete a record, click on the toolbox icon in the row of the deletable record, choose "Delete" and confirm the deletion in the dialog.

The toolbox widget is also available on the top right of the the edit view.

{% comment %} :TODO: link to instructions about customizing toolboxes {% endcomment %}





















