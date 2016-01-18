---
title: "OLD: Fields overriding"
weight: 1003
subitems:
  -
    title: Generic partials overriding
    anchor: fields-override
  -
    title: Field specific overriding
    anchor: fields-specific-override
---

## Fields overriding

Releaf by default tries to render everything in such a way that programmer rarely should override some partials to display content in desired way.

However when there's need to render some fields differently there are some quick options.

### Generic partials overriding {#fields-override}

Every controller that inherits from [Releaf::BaseController](https://github.com/cubesystems/releaf/blob/master/app/controllers/releaf/base_controller.rb) will automatically try to render object. To do this it will use partials from [app/views/releaf/base](https://github.com/cubesystems/releaf/tree/master/app/views/releaf/base).

When needed any one of them can be overridden by creating partial with same name in views directory.
This can be used to completely override text fields in given view for example.

### Field specific overriding {#fields-specific-override}

TODO
