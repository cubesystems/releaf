---
title: "Configuration"
weight: 1000
---

# Releaf configuration overview

Various aspects of Releaf can be configured via the releaf initializer file located at

```
config/initializers/releaf.rb
```

* [Defining locales](#locales)
* [Defining controllers and main menu items](#menu)
* [Customizing used components](#components)
* [Using a custom layout](#layout)

{% comment %} :TODO: write about config.devise_for {% endcomment %}

## Defining locales {#locales}

Locales used by Releaf can be defined as an array:

```ruby
config.available_locales = ["en", "lv"]
```

Note that locales defined here are not necessarily all the locales used by the application.

These are just the locales in which the Releaf admin interface itself will be available.
{% comment %} :TODO: link to description of how users can change their admin interface locale. {% endcomment %}


## Defining controllers and main menu items {#menu}

The `config.menu` array defines the main menu structure.

It may contain hashes with either a `:controller` key for a first-level item or `:name` and `:items` keys for a second level of nested menu items, e.g.:

```ruby
config.menu = [
  { controller: 'admin/nodes' },
  {
    name:  'inventory',
    items: %w[admin/books admin/authors admin/publishers]
  },
]
```
{% comment %} :TODO: update releaf and dummy generators to use modern hash syntax {% endcomment %}

Controllers that should not be included in the main menu but should still be accessible may be added to `config.additional_controllers` array.

See the [Creating controllers](../../creating-controllers/) chapter for the general principles of how the Releaf main menu works.


## Customizing used components {#components}

By default, Releaf comes with its four main components enabled:

```ruby
config.components = [
  Releaf::Core,
  Releaf::I18nDatabase,
  Releaf::Permissions,
  Releaf::Content
]
```

Any of these, except `Releaf::Core`, may be removed if not needed. When removing a component, make sure to also remove its related entries from `config.menu`.

A component may have its own specific configuration keys. These are scoped under the respective component key, e.g. the `resources` configuration option of `Releaf::Content` component can be set via `config.content.resources` key.

Component-specific configuration options are described in the Configuration chapters of each bundled component.

{% comment %} :TODO: links to respective documentation sections for disabling each component {% endcomment %}
{% comment %} :TODO: link to chapters about using optional components and writing new ones {% endcomment %}

## Using a custom layout {#layout}

The builder class used for rendering the Releaf layout can be overridden like this:

```ruby
config.layout_builder_class_name = "CustomLayoutBuilder"
```

{% comment %} :TODO: link to documentation section about customizing layout {% endcomment %}




