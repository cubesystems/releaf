---
title: "Disabling default actions"
weight: 1400
---

# Disabling default actions

Releaf has a set of defined controller features which are linked to the built-in actions.

Each feature can either be turned on or off.

If a feature is disabled, its related actions become unavailable.

The default features are as follows:

* `:create` - whether new resources can be created
* `:create_another` - whether the "Save and create another" button should be shown
* `:edit` - whether existing resources can be edited
* `:destroy` - whether existing resources can be deleted
* `:index`  - whether the listing of all resources is available
* `:search` - whether the default built-in search feature is available in the Index view
* `:toolbox` - whether the toolbox widget is available for each resource

To disable some of the features, override the `features` method in the controller:

```ruby
class Admin::BooksController < Releaf::ActionController

  def features
    super - [:edit, :destroy]
  end

end
```

