---
title: "Changing the resource class"
weight: 1600
---

# Changing the controller's resource class

By default, Releaf automatically calculates the model class to use from the controller's class name by removing the top namespace.

Some examples:

`Admin::BooksController` will use the `Book` model.
`Admin::Library::BooksController` will use the `Library::Book` model.
`BooksController` will use the `Book` model.

If the automatically calculated resource class name is not what is needed, it can be overridden with `resource_class` class method.

```ruby
class Admin::BooksController < Releaf::ActionController

  def self.resource_class
    Library::Book
  end

end
```

If your application does not have a public website, and therefore does not use a top-level namespace like `Admin::` for its controllers, you can [define your own intermediate controller](../common-patterns/#intermediate-controller) that includes its own automatic model detection for all your controllers:

```ruby
class AdminController < Releaf::ActionController
  def self.resource_class
    self.name.sub(/Controller$/, '').classify.constantize
  end
end

class Library::BooksController < AdminController
  # resource class will be Library::Book
end
```




