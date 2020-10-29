---
title: "New and Edit actions"
weight: 1200
---

# Working with New and Edit actions

New and Edit actions render a form for creating or updating a resource.

By default, Releaf renders fields for all attributes of the model, except `id`, `created_at` and `updated_at`.

The input control types used for each field are automatically detected from the model's attributes.

See the [Customizing views chapter](../../builders/) for instructions on customizing the fields.

When the resource is being saved, all model validations are performed and any errors are displayed under the respective fields.

After saving, the user is redirected to either the Edit or New view depending on whether the "Save" or "Save and create another" button was clicked.

