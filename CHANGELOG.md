## Changelog

### 2013.10.17

* Moved ```Releaf::BaseController#resource_class``` functionality to
  ```Releaf::BaseController.resource_class```.
  ```Releaf::BaseController#resource_class``` now calls ```Releaf::BaseController.resource_class```.
  Everywhere, where ```Releaf::BaseController#resource_class``` was overriden,
  you must update your code, to override
  ```Releaf::BaseController.resource_class```
* Renamed ```@resources``` to ```@collection```
* Renamed ```Releaf::BaseController#resources_relation``` to ```Releaf::BaseController#resources```
* Updated html and css to use collection class instead of resources class
