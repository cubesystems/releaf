---
title: Common usage patterns
weight: 1700
---

# Common controller usage patterns

This chapter describes some common patterns that we've found useful when working with Releaf controllers.

* [An intermediate application-wide controller](#intermediate-controller)

## An intermediate application-wide controller {#intermediate-controller}

If you find yourself repeating the same customizations for all your controllers, it is recommended to define an intermediate controller class which all your controllers will inherit from instead of extending them from `Releaf::ActionController` directly.

```ruby
class AdminController < Releaf::ActionController
  # any shared application-wide controller code here
end

class Admin::BooksController < AdminController; end
class Admin::AuthorsController < AdminController; end
```
