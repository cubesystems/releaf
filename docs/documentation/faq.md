---
title: Q & A
weight: 7
---

## Q & A

### Q: How to use custom admin model?

in ```config/initializers/releaf.rb``` set

```ruby
Releaf.application.config do
  config.devise_for = 'custom_admin'
end
```
Where custom_admin is underscored name of you custom admin model.
Don't forget to restart rails.

