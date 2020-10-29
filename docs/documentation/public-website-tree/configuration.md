---
title: "Configuration"
weight: 2000
---

# Releaf::Content component configuration

Like other components, `Releaf::Content` can be customized via the releaf initializer file located at

```
config/initializers/releaf.rb
```

* [Customizing node tree model and controller](#resources)
* [Setting up multiple separate node trees](#multinode)

## Customizing node tree model and controller {#resources}

The node model and/or controller used in the content tree may be overridden via `resources` setting, e.g.:

```ruby
config.content.resources = {
  'Node' => { controller: 'Admin::NodesController' }
}
```

When changing the controller, make sure to update the corresponding `config.menu` array entry as well.


{% comment %} :TODO: link to chapter about overriding node model and/or controller {% endcomment %}

## Setting up multiple separate node trees {#multinode}

To use separate node trees for handling multiple websites, add multiple entries to the `resources` key, e.g.:

```ruby
config.content.resources = {
  'Node' => {
    controller: 'Releaf::Content::NodesController',
    routing: {
      site: "main_site",
      constraints: { host: /^(www\.)?releaf\.local$/ }
    }
  },
  'OtherSite::OtherNode' => {
    controller: 'Admin::OtherSite::OtherNodesController',
    routing: {
      site: "other_site",
      constraints: { host: /^(www\.)?other\.releaf\.local$/ }
    }
  }
}
```

Each entry must have an additional `routing` key defining routing constraints for each site. This is needed to ensure that nodes with matching slugs across separate content trees do not cause routing conflicts.

When adding new node controllers, make sure to add them to the `config.menu` array as well.

{% comment %} :TODO: write intro and config example here and link to multinode chapter {% endcomment %}




