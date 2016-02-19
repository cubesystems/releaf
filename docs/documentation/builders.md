---
title: Customizing views
weight: 1600
---

# Customizing views

All views in Releaf are rendered using special classes called **builders**.

Instead of rendering views by including many different view partials, Releaf controllers call the `output` method on an instance of the respective builder class corresponding to each view.

There are many different builders, each used for its specific purpose.

For example, the Edit view is rendered by `Releaf::Builders::EditBuilder`, the table in the Index view is rendered by `Releaf::Builders::TableBuilder`, and so on.

Each controller can either use the default builders provided by Releaf, or use a custom builder for any part of any view.

To customize something in a view, simply create a new builder class, inherit from the corresponding default builder and override any needed methods.

Custom builder classes ar detected by controllers automatically if they are named according to the conventions and placed in the `app/builders/` folder.

There are multiple advantages in using builder classes instead of rendering nested view partials:

* **Easy customization.** Override any method in any builder to make it render any aspect of the view differently.
* **High granularity.** Builders have their code split into many tiny methods, each responsible for a small fragment of the resulting HTML. Therefore, it is possible to override only a specific part of the output without having to copy its surrounding code.
* **Easy testing.** All code should have tests written for it, and writing thorough unit tests for small methods in customized builders is much easier than writing tests for view partials.
* **Fast perfomance.** Rendering lots of nested partial files can get slow quite quickly. Builders do not have this problem.

A couple of quick examples for illustration:

To add an Export button in the footer of the Index view of `Admin::BooksController`, create a file at `app/builders/admin/books/index_builder.rb` with the following content:

```ruby
class Admin::Books::IndexBuilder < Releaf::Builders::IndexBuilder

  def footer_secondary_tools
    [ export_button ]
  end

  def export_button
    url = action_url(:export, format: :xlsx)
    button(t("Export"), "download", class: "secondary", href: url)
  end

end
```

To change the columns displayed in the Index view of `Admin::BooksController`, create a file at `app/builders/admin/books/table_builder.rb`:

```ruby
class Admin::Books::TableBuilder < Releaf::Builders::IndexBuilder

  def column_names
    %{title year published_at}
  end

end
```


{% comment %} :TODO: write ending, add links to details {% endcomment %}


{% comment %} :TODO: describe customization of index tables {% endcomment %}

{% comment %} :TODO: describe customization of edit forms, including setting permitted_params and accepts_nested_attributes_for {% endcomment %}

{% comment %} :TODO: describe customization of footer (additional buttons etc) {% endcomment %}


