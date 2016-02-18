---
title: "Adding custom actions"
weight: 1500
---

# Adding custom actions

Adding a new action to a Releaf controller usually consists of the following steps:

1. [Add the action method to the controller](#action)
2. [Add the action to routes](#routes)
3. [Customize the view](#view)

This example adds an Export action to the `Admin::BooksController`

## Add the action method to the controller {#action}

A new action is simply a new method in the controller.

```ruby
class Admin::BooksController < Releaf::ActionController

  def export
    # implement book export code
  end

end
```

## Add the action to routes {#routes}

To add custom routes to the controller, pass a block to `releaf_resources` in the `routes.rb` file, just like normally in Rails.

```ruby
mount_releaf_at '/admin' do

  releaf_resources :books
    collection do
      get :export
    end
  end

end
```

## Customize the view {#view}

The new action will probably need some way of getting to it from the view.

In the Export action example, the Index view would need an additional Export button in the footer.

Doing this is described in the [Customizing views chapter](../views.html)

{% comment %} :TODO: link to the correct section about customizing views {% endcomment %}


