## Changelog

### 2013.10.17

* Move ```Releaf::BaseController#resource_class``` functionality to
  ```Releaf::BaseController.resource_class```.

  ```Releaf::BaseController#resource_class``` now calls ```Releaf::BaseController.resource_class```.

  Everywhere, where ```Releaf::BaseController#resource_class``` was overriden,
  you must update your code, to override
  ```Releaf::BaseController.resource_class```

