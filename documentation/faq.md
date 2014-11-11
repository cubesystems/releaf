---
title: Q & A
weight: 7
---

## Q & A

### Q: How to use custom admin model?

in ```config/initializers/leaf.rb``` set

```ruby
Leaf.setup do |conf|
  conf.devise_for = 'custom_admin'
end
```
Where custom_admin is underscored name of you custom admin model.
Don't forget to restart rails restart rails.

### Q: How to use Leaf::Slug module in models?
Add this code to your model.

```ruby
acts_as_url :name, :url_attribute => :slug, :scope => :parent_id
include Leaf::Slug
```

Leaf::Slug will override ```to_html``` and add ```find_object``` methods

Notes:

1. **scope** is optional
1. you can specify any other attribute instead of **name**
1. ```:url_attribute => :slug``` is mandatory


