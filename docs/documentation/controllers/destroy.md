---
title: "Destroy action"
weight: 1300
---

# Working with Destroy action

Existing resources can be deleted by clicking the Delete item in the resource's toolbox.

The toolbox is available from both Index and Edit views.

Before deletion, the user is presented with a built-in confirmation dialog.

If the resource has related records in an association defined with

```dependent: :restrict_with_exception```

option, a message will be displayed indicating that the record cannot be destroyed.


{% comment %} :TODO: link to a section describing possible customizations of destroy confirmation dialog {% endcomment %}