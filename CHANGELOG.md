## Changelog

### 2014.07.02
* TinyMCE replaced by CKEditor as built-in WYSIWYG field editor

### 2014.07.01
* Settings module renamed to Releaf::Settings.
* Releaf::Core::SettingsUIComponent component added.
  More there: https://github.com/cubesystems/releaf/wiki/Settings

### 2014.06.09
* Richtext attachments moved to releaf component/controller concern.
  More there: https://github.com/cubesystems/releaf/wiki/Richtext-editor

### 2014.05.28
* Removed Releaf::TemplateFilter includable module.
* Refactored how releaf stores form templates.
  Form templates are now stored in containers data-releaf-template html attribute.

### 2014.05.15
* Releaf::ResourceValidator was renamed to Releaf::ErrorFormatter.
  Releaf::ErrorFormatter.build_validation_errors was renamed to .format_errors.

  If you used Releaf::ResourceValidator.build_validation_errors, update your
  code to use Releaf::ErrorFormatter.format_errors.

### 2014.05.14
* Releaf::ResourceValidator was rewriten.
  .build_validation_errors now only needs one argument - resource to validate.

  It will now use "activerecord.errors.messages.[model_name]" as I18n scope for errors
* BaseController 'index_row_toolbox' feature renamed to 'toolbox'

### 2014.05.09
* Translation group removed
* Translations refactored

### 2014.05.01
* Dragonfly updated from 0.9 to 1.0
  Update instructions there: https://github.com/markevans/dragonfly/wiki/Upgrading-from-0.9-to-1.0

### 2014.04.30
* removed #protected attribute from releaf node
* To render locale selection for content node override
  \#locale_selection_enabled? method to return true for nodes that need locale
  selector.

  This means that Releaf no longer check for releaf/content/_edit.locale
  partial. This partial will be ignored.
  
  Rename Releaf::Permissions::Admin to Releaf::Permissions::User, 
  change table name from releaf_admins to releaf_users
* Modify releaf_roles.permisions to match changed naming for releaf/content/nodes, releaf/permissions/users,   releaf/permissions/roles, releaf/i18n_database/translations
* Modify releaf_roles.default_controller to be an existing one (for example from releaf/content to releaf/content/nodes)
* Modify config/initializers/releaf.rb to use releaf/content/nodes, releaf/permissions/users, releaf/permissions/roles, releaf/i18n_database/translations

### 2014.04.28
* Refactored notification rendering (introduced
  Releaf::BaseController#render_notification) method.

  Now notifications by default will consist of action name and "succeeded" or
  "failed" word. For example flash notice "Updated" will now be
  "Update succeeded".

### 2014.04.25
* It is no longer required to add :id to permit_attributes options for
  ActiveRecord models, when using acts_as_node. It'll be added automatically,
  when permit_attributes option is used.

### 2014.04.23
* Converted Releaf::Node to Releaf::Contnet::Node module.

  Instread of inheriting from Releaf::Node, inherit from ActiveRecord::Base and
  include Releaf::Content::Node

### 2014.04.22
* Releaf::Node is in refactoring process. The goal is to make it an abstract
  model (some day)

  All existing projects that use Releaf::Node should create Node model that inherits
  from Releaf::Node. You will either need to rename releaf_nodes table to
  nodes or set table_name in Node model.

  In all of your code you should use Node model now (instead of Releaf::Node).
  This includes migrations as well.

  If you used Releaf::Node model in migrations, then it might be nessacery to
  rename releaf_nodes table renaming migration in such a way, that it renames
  table, before any other migration needs to access Node. Otherwise you'll get
  chicken and egg situation, when migration tries to access nodes table, while
  releaf_nodes table will be renamed to nodes much later.

  Currently there is no way to specify alternative Node model.

* Got rid of common fields.

  If you were using common fields, you should migrate your data from common
  fields seralized hash (in data attribute), to attribute per common field.

* To use new common field attributes, crete method 'own_fields_to_display' in your node model, that returns common attributes, for example:
  def own_fields_to_display
    [:page_title, :meta_description]
  end

* Remove custom validations support from Releaf::Node via acts_as_node.

  Instead you should add custom validations to your Node model

* Renamed Releaf::Node::Route to Releaf::ContentRoute

### 2014.04.09
* remove Releaf::Node#content_string field, as it was't used
* Extend Releaf::Node#data column to 2147483647 characters

### 2014.01.02
* ```additional_controllers``` Releaf configuration variable introduced. Add
  controllers that are not accessible via menu, but needs to be accessible by
  admins to this list.  These controllers will have permission checkbox in
  roles edit view, just like the rest of controllers in ```Releaf.menu```.

### 2013.12.05
* \#build_validation_errors, #validation_attribute_name,
  \#validation_attribute_field_id, and #validation_attribute_nested_field_name
  were extracted from Releaf::BaseController to Releaf::ResourceValidator module.
  If you called any of these methods manually, then you'll need to update your
  controllers. Also Releaf::ResourceValidator.build_validation_errors now
  accept two arguments: resource and error message scope (check the source from
  details)

* Extracted functionality of filtering templates from params from
  Releaf::BaseController to Releaf::TemplateFilter includable module.
  You can now include this module in your controllers if you want similar
  functionality.


### 2013.11.01
* Bump font-awesome-rails to >= 4.0.1.0. If you use it, update all
  html/css/javascript to use new font awesome classes


### 2013.10.24

* Removed long unused lighbox javascript
* ajaxbox now checks presence of ```data-modal``` attrubute instead of it's value. Update your views.
* If you want to open image in ajaxbox, you need to add ```rel="image"``` html attribute to links.


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
* Richtext field height will be set to outerHeight() of textarea
* ```Releaf::BaseController#render_field_type``` was extracted to
  ```Releaf::TemplateFieldTypeMapper``` module.
  It's functionality was split.

  ```ruby
    render_field_type, use_i18n = render_field_type(resource, field_name)
  ```

  should now be rewriten to

  ```ruby
    field_type_name = Releaf::TemplateFieldTypeMapper.field_type_name(resource, field_name)
    use_i18n = Releaf::TemplateFieldTypeMapper.use_i18n?(resource, field_name)
  ```
* created new helper method ```ajax?```. If you were checking
  ```params[:ajax]``` or ```params.has_key?(:ajax)``` etc, then you should
  update your code to use ```ajax?```.

  ```:ajax``` parameter is removed from ```params``` has in ```manage_ajax```
  before filter in ```Releaf::BaseApplicationController```
