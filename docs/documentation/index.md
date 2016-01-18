---
title: Introduction
weight: 1000
---

# What is Releaf?

Releaf is an administration interface for Rails applications.

It consists of four components:

* __Releaf core__
  * Automatic CRUD views and actions
  * Full customization of controllers and views when defaults are not enough
* __Permission system__ (optional)
  * User management and authentication
  * Role-based access control to admin controllers
  * Easily replaceable with a different access control mechanism if needed
* __I18n database backend__ (optional)
  * I18n translation texts stored in a database
  * User-editable translations via admin interface instead of YAML files
* __Website content tree__ (optional)
  * Public website tree structure administration
  * Dynamic page routes with user-editable slugs