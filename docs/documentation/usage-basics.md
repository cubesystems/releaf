---
title: Usage basics
weight: 1200
---

# Usage basics

## General principles

At its core, Releaf provides a mechanism for quick creation of custom administration panels without having to reimplement all of the usual CRUD boilerplate each time.

Every aspect of the initial default behaviour can be fully customized later.

The simplest typical case goes as follows:

1. Create an ActiveRecord model with some attributes.
2. Create a controller for the model by extending Releaf's base controller (1 line of code).
3. Add the controller to Releaf routes (1 line of code).
4. Add the controller to Releaf navigation menu (1 line of code).
5. Grant access to the controller to an administrator role (1 tick in the permissions panel).

These steps are described in more detail in the [Creating controllers](creating-controllers.html) chapter.

After doing this, the new controller will become available as an item in Releaf's sidebar menu.

{% comment %} :TODO: add screenshots of sidebar and default views to illustrate the result {% endcomment %}

It will immediately have the following actions and views working out of the box:

* __Index__
  * A table listing all existing records of the respective model
  * All attributes of the model displayed as columns
  * Built-in search through all displayed text attributes
  * Pagination
* __Creation and editing__
  * Automatically generated forms
  * Input fields for all editable attributes of the model
  * Field types automatically detected from model attribute types and names
  * Validation messages according to the rules defined in the model
  * Localizable attribute labels with human-readable defaults
* __Deletion__
  * Delete buttons available from both index and edit views
  * Confirmation dialog before deletion

{% comment %} :TODO: which attributes are searchable by default? {% endcomment %}

It will then be possible to start [customizing the controller](controllers.html) and its [views](views.html) as needed.

## Building a public website CMS

If the application has a public website side as well (i.e., some non-administrative views available to other users), Releaf can be used to create and manage the tree structure of that part of the application as well.

For more on that, read the [Public website tree](public-website-tree.html) chapter.



{% comment %}  :TODO: general principles of menu, navigation, permissions {% endcomment %}




