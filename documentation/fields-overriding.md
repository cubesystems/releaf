---
title: Fields overriding
weight: 3
---

## Fields overriding

Releaf by default tries to render everything in such a way that programmer rarely should override some partials to display content in desired way.

However when there's need to render some fields differently there are some quick options.

### Generic partials overriding

Every controller that inherits from [Releaf::BaseController](https://github.com/cubesystems/releaf/blob/master/app/controllers/releaf/base_controller.rb) will automatically try to render object. To do this it will use partials from [app/views/releaf/base](https://github.com/cubesystems/releaf/tree/master/app/views/releaf/base).

When needed any one of them can be overridden by creating partial with same name in views directory.
This can be used to completely override text fields in given view for example.

### Field specific overriding

However most of the time you want to override something for a specific field. In this case you need to create field specific partial.

For example if you have Bank that has many accounts, that has account_number and you want to override how it's displayed (Imagine that in Edit view you render bank fields and nested objects (account) fields)

To ovverride account_number you need to create **_edit.field.bank.accounts.account_number.html.haml** file.

the following local variables will be passed to partial:
* f - form builder instance
* name - name of field to be rendered
* view_prefix - this is used internally, if you aren't planning to render any nested objects from current partial, you don't need to know about it

With all this you can do just about everything you need.

You can get current object (account in this case) with **f.object**

Now back to overriding. You have 2 options, either to write 100% custom partial, or you can render one of releaf stock partials, with some custom options.

for example

```ruby
= render 'field.type_text', :f => f, :name => name, :input_attributes => { :disabled => :disabled }, :label_options => { :description => 'This is a custom field' }
```

#### input_attributes
Input attributes will be passed to input (either input, select or textarea), these will be rendered as input attributes.

For example in above sample code, input would be disabled ;)

#### label_options
These options are passed to [_edit.field_label](https://github.com/cubesystems/releaf/blob/master/app/views/releaf/base/_edit.field_label.html.haml) partial. You can view it's source to see what options are available.

The most common option that you'll use is **description**, ex.:

```ruby
= render 'edit.field', f: f, name: name, label_options: { description: 'This is a custom field' }
```

#### field_attributes
Similar to input_attributes, field_attributes will be passed to field and rendered as html attributes.
This can be useful to add some style to field for example.

```ruby
= render 'show.field_type_text', :resource => resource, :name => name, :field_attributes => { :style => object.new_record? ? 'display:none;' : nil }
```

field_attributes can be used in both edit and show partial
