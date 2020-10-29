---
title: Introduction
weight: 1000

---

# What is Releaf?

Releaf is an administration interface for Rails applications.

It consists of four main components:

* __Releaf core__
  * [Automatic CRUD views and actions](usage-basics/)
  * Full customization of [controllers](controllers/) and [views](builders/) when defaults are not enough
* __Permission system__ (optional)
  * User management and authentication
  * Role-based access control to admin controllers
  * Easily replaceable with a different access control mechanism if needed
* __I18n database backend__ (optional)
  * [I18n translation texts stored in a database](i18n-database/)
  * Translations editable by users via admin interface instead of YAML files
* __Website content tree__ (optional)
  * [Public website tree structure administration](public-website-tree/)
  * Dynamic page routes with user-editable slugs

{% comment %} :TODO: mention other optional components like releaf-sidekiq and releaf-settings-ui {% endcomment %}

See [Installation](installation/) chapter for instructions on setting it up.