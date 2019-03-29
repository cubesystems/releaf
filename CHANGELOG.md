## Changelog

### 1.1.21 (2019.03.29)

* Add correct time formatting in table builder

### 1.1.20 (2018.11.13)

* Fix a bug in has_error? matcher

### 1.1.19 (2018.09.17)

* Fix CKEditor 4.9 file upload issue

### 1.1.18 (2018.08.08)

* Use respond_with for show action

### 1.1.17 (2018.06.15)

* Fix sidebar css for compact view

### 1.1.16 (2018.06.06)

* Minor rspec `auth_as_user` helper improvement for better user instance
  support

### 1.1.15 (2018.03.29)

* Add richtext support to `Releaf::Settings`

### 1.1.14 (2018.03.29)

* Fix a problem with content tree building

### 1.1.13 (2018.01.18)

* Initialize search form via `contentloaded` event

### 1.1.12 (2018.01.18)

* Add more convient way to detect whether menu item is group

### 1.1.11 (2018.01.16)

* Fix broken admin controller custom routes helper support
* Use controller definition path for resolving default controller
  redirect

### 1.1.10 (2017.12.20)

* Add textarea support to `Releaf::Settings`

### 1.1.9 (2017.12.15)

* Fix a bug that always regenerated slugs from content node titles during copying
* Improve performance in case of many content nodes
* Return content node instance from copy and move service calls

### 1.1.7 (2017.09.10)
* Fix breacrumbs link for controllers for "show" method instead of "edit"

### 1.1.6 (2017.08.31)
* Add "cache_instance_method" rspec matcher

### 1.1.5 (2017.06.07)
* Fix an incompletely merged PR

### 1.1.4 (2017.06.07)
* Fix a localization issue with datetime fields

### 1.1.3 (2017.04.04)
* Correctly return empty features array for Releaf::RootController

### 1.1.2 (2017.04.04)
* Render Releaf 404 error page when resource is not found
* Remove "go home" link from error pages

### 1.1.1 (2017.03.22)
* Fix pluralization support for `releaf-i18n_database` to return correct pluralization
* Remove "twitter_cldr" in favour of "rails-i18n" gem for translation
  pluralization support in `releaf-i18n_database`

### 1.1.0 (2017.02.23)
* Added layout features. Controller from now can choose which parts(header, sidebar, main) must be rendered
* Added support for CKEditor filebrowserBrowseUrl configuration

### 1.0.10 (2017.02.22)
* Fix broken content nodes copy and move dialogs

### 1.0.9 (2017.02.21)
* Deep copy support added for node content objects

### 1.0.8 (2017.01.31)
* Make Releaf resource creation MS Edge compatible by using html5
  history API to load new resource location and content when created with
  xhr

### 1.0.7 (2016.12.28)
* `Releaf::Builders::FormBuilder` now has a separate `releaf_has_many_association_attributes` method that can be overridden in custom builders to add extra HTML attributes to a nested item section

### 1.0.6 (2016.12.18)
* Make possible to safely use translations in routes while using `releaf-i18n_database` gem

### 1.0.5 (2016.12.06)
* Added slug format validation for content nodes
* Fixed broken "Save and create another" feature

### 1.0.4 (2016.11.01)
* fix builder scope resolving in cases when application scope has `nil`
  value

### 2016.10.21
* `Releaf.application.config.i18n_database.translation_auto_creation_patterns` configuration variable added for custom
  translation auto creation patterns matching. Default value is `[ /.*/ ]` to create all incoming keys.

### 2016.10.17
* `application_builder_scope` method from controller removed.
* controller will try to resolve builders also in application wide
  scope (ex. from now it is possible to have `Admin::FormBuilder` for application wide default admin form builder)

### 2016.10.15
* `Releaf::InstanceCache` has been rewrited for more convient way to define methods to cache.
  It is possible to define either single or array of methods to cache:
  ```
  def SomeClass
    include Releaf::InstanceCache
    cache_instance_methods :some_value, :another_value
    cache_instance_method :some_value

    def some_value
      :a
    end

    def another_value
      :b
    end

    def totally_another_value
      :c
    end
  end
  ```

### 2016.10.11
* `Releaf.application.config.i18n_database.create_missing_translations`
  config renamed to `Releaf.application.config.i18n_database.translation_auto_creation`
* I18n.t `create_missing` option renamed to `auto_create`
* I18n.t `create_default` option removed
* Use chained translation backends with `Releaf::I18nDatabase::Backend` as primary and
  `I18n::Backend::Simple ` as secondary backend
* `Releaf.application.config.i18n_database.translation_auto_creation_exclusion_patterns` config
  added with default value `[/^attributes\./]` to ignore default translations comming from activerecord
  attribute humanization method.
* It is possible to add  custom regexp patterns to prevent certain translations to be created
  in database (for example add `config.i18n_database.translation_auto_creation_exclusion_patterns += [/^activerecord\.attributes\./]`
  to your Releaf initializer to prevent `activerecord.attributes.*` creation)
* As there is backend chain available, it is recommended to create default,
  hardcoded translations (date and number formats for example) with
  standart localization yml files (config/locales/*.yml)
* `I18n.backend.translations_cache.locales_pluralizations` method moved to `Releaf::I18nDatabase::Backend.locales_pluralizations`
* It is possible to reset Releaf translation cache with `Releaf::I18nDatabase::Backend.reset_cache`

### 2016.08.15
* `Releaf::TestHelpers` test helpers renamed to `Releaf::Test::Helpers`
* For better Releaf tests behaviour add `Releaf::Test.reset!` to `RSpec.after(:each)`

### 2016.08.10
* Controllers `current_url` and `index_url` methods renamed to `current_path` and `index_path`

### 2016.07.22
* `form_options`, `form_attributes` and `form_url` methods moved from Releaf::ActionController to `Releaf::Builders::EditBuilder` as its edit builder responsibility for it's own content
* `Releaf::Builders::EditBuilder` for now have `#form_builder_class`
  method for custom form builder class overriding
* `table_options` method moved from Releaf::ActionController to `Releaf::Builders::IndexBuilder`

### 2016.07.19
* `Releaf::ItemOrderer` refactored to `Array::Reorder` service
* Array now have #reorder method for simple array reordering
* You must update builders from old reorder code to new syntax:
```
def field_names
  orderer(super).reorder(:title, :first).result
end
```
now can be written simple as:
```
def field_names
  super.reorder(:title, :first)
end
```

### 2016.03.09
* `Releaf::ControllerDefinition` implemented for unified controller
  meta-data handling. Custom menu builders need to be rewritted to use
controller definition instead of hash instance.

### 2016.03.07
* `Releaf::ErrorFormatter` refactored as `Releaf::BuildErrorsHash` service.
Also, extra features as `full_message` and `data` passing to errors hash has been removed.
For this kind of features, extend `Releaf::BuildErrorsHash` service and
add all additional feautures to your custom class.

### 2016.02.28
* Object title resolvation refactored.
From now `to_text` need to be renamed to `releaf_title` in existing
project.
Releaf will try to check whether method exist and then return its
result.
Resolvable methods list: `releaf_title`, `name`, `title`, `to_s`.
You can migrate you existing `to_text` methods with:
```
perl -p -i -e 's/to_text/releaf_title/g' `grep -ril "to_text" *`
```

* Translations models and tables renamed.

create migration `rails g migration RenameReleafI18nBackendTables`
and put following content in migration file:
```
class RenameReleafI18nBackendTables < ActiveRecord::Migration
  def up
    remove_index :releaf_translation_data, name: "index_releaf_translation_data_on_lang_and_translation_id"
    rename_table :releaf_translations, :releaf_i18n_entries
    rename_table :releaf_translation_data, :releaf_i18n_entry_translations
    rename_column :releaf_i18n_entry_translations, :translation_id, :i18n_entry_id
    rename_column :releaf_i18n_entry_translations, :lang, :locale
    rename_column :releaf_i18n_entry_translations, :localization, :text
  end

  def down
    rename_table :releaf_i18n_entries, :releaf_translations
    rename_table :releaf_i18n_entry_translations, :releaf_translation_data
    rename_column :releaf_translation_data, :i18n_entry_id, :translation_id
    rename_column :releaf_translation_data, :locale, :lang
    rename_column :releaf_translation_data, :text, :localization
    add_index :releaf_i18n_entry_translations, [:locale, :i18n_entry_id], unique: true,
      name: :index_releaf_i18n_entry_translations_on_locale_i18n_entry_id
  end
end
```

remove `allow_any_instance_of(Releaf::I18nDatabase::Backend).to receive(:reload_cache?) { false }` line from your
`spec/rails_helper.rb`

### 2016.02.17
* Remove db level uniqueness index for translations key.

create migration `rails g migration ChangeReleafTranslationsKeyIndexType`
and put following content in migration file:
```
class ChangeReleafTranslationsKeyIndexType < ActiveRecord::Migration
  def up
    remove_index :releaf_translations, :key
    add_index :releaf_translations, :key
  end

  def down
    remove_index :releaf_translations, :key
    add_index :releaf_translations, :key, unique: true
  end
end

```

### 2016.02.16
* all Releaf controller assets (javascripts and stylesheets) moved from `releaf/controllers/releaf/controller_name`
  pattern to `controllers/releaf/controller_name`.
  If you have existing controller assets that inherit Releaf controller
  assets simply remove first `releaf/` part.
  ex. `//= require releaf/controllers/releaf/content/nodes` to `//= require controllers/releaf/content/nodes`

### 2016.02.11
* `Releaf::Settings.register` method refactored to accepts list of hashes as arguments.
  ex. `Releaf::Settings.register({key: "some.thing", default: "some day"}, {key: "color", default: "red"})`

### 2016.02.05
* `:search` feature added. When custom `features` method provided, add `:search`
  to returned array if search is needed.
* `Releaf::BaseController` renamed to `Releaf::ActionController`. Update
  all your code with:
```
perl -p -i -e 's/Releaf::BaseController/Releaf::ActionController/g' `grep -ril "Releaf::BaseController" *`
```
* Releaf::ActionController `setup` has been removed in favour of `features` and `resources_per_page` methods.
* Releaf::ActionController `features` must return array with allowed features instead of Hash with
  true/false values.
```
def setup
  super
  self.features = {
    edit: true,
    index: true,
  }
  self.resources_per_page = 15
end
```
can be rewritted as:
```
def features
  [:index, :edit]
end

def resources_per_page
  15
end
  ```

### 2016.02.04
* All `Releaf::Core::` namespaces replaced with `Releaf::` except Releaf::Core component.
  To update site, you need to:
    * Replace all `Releaf::Core::` to `Releaf::` with only exception
      `Releaf::Core` component within `config/initializer/releaf.rb`
      componets section. Replacement script:
      ``perl -p -i -e 's/Releaf::Core/Releaf/g' `grep -ril "Releaf::Core" * | grep -v "config/initializers/releaf.rb"` ``
    * Replace `releaf/core/settings` to `releaf/settings` within `config/initializer/releaf.rb` menu config.

### 2016.02.02
* `Releaf.application.config.assets_resolver_class_name` configuration option removed in favour of custom builder. If there are need for custom assets resolver, create new page layout builder and override assets resolver in builder.

### 2016.01.30
* Releaf core fully decoupled from any authentication and user/role dependancies. It is possible to not use "releaf-permissions" at all and have userless system or swap with other authorization subsystem.
* Configuration refactored to be more component-centric.
* `virtus` gem added for simple model creation. Service classes can be created by adding `include Releaf::Core::Service`. Service call is accessable by `call` with all arguments defined within service
* `config/intializers/releaf.rb` updates:
  * Add `Releaf::Core` as first component to `config.components` configuration
  * Remove `Releaf::Core::SettingsUI` from `config.components` configuration
  * Remove `releaf/permissions/profile` from `config.additional_controllers` configuration
* `spec/rails_helper.rb` updates
  * Remove `Releaf::I18nDatabase.create_missing_translations = false`
  * Add `allow( Releaf.application.config.i18n_database ).to receive(:create_missing_translations).and_return(false)` within `before(:each)` block


### 2016.01.28
* *Component suffix has been removed. Releaf initializer needs to be
  updated if components has been specified.

### 2016.01.11
* `.nodes` and `#node` methods removed from default `acts_as_node` models and controllers
  due to implementing support for multiple node classes.

  If reverse node lookup from content classes is needed, reimplement it
  in the specific application where the needed node class name is known.
* Builder scopes in admin controllers are now inherited from parent controllers up to `Releaf::BaseController`.
* Magic `Admin::Nodes` builder scope is no longer prepended by `Releaf::Content::NodesController`.

  This is no longer needed because releaf controllers can now be extended
  and the child controllers can have their own builders.

  Note that controller assets are not automatically inherited and need
  to be explicitly loaded by the child controller.

  Updating applications that use custom `Admin::Nodes` builder scope:
  (see Dummy application for a working example)

  1) Create `Admin::NodesController < Releaf::Content::NodesController`

  2) Change releaf menu in `config/initializers/releaf.rb`:

  Instead of
  ```ruby
  {
    :controller => 'releaf/content/nodes',
    :icon => 'sitemap',
  }
  ```

  Use
  ```ruby
  { :controller => 'admin/nodes' }
  ```

  3) Override node resource configuration in `config/initializers/releaf.rb`:

  Add the following:
  ```ruby
  config.content.resources = { 'Node' => { controller: 'Admin::NodesController' } }
  ```

  4) Create `app/assets/javascripts/controllers/admin/nodes.js` with the following content:
  ```
  //= require releaf/controllers/releaf/content/nodes
  ```

  5) Create `app/assets/stylesheets/controllers/admin/nodes.scss` with the following content:
  ```
  @import 'releaf/controllers/releaf/content/nodes';
  ```

  6) Make sure that controller assets of the application are being precompiled.

  This can be enabled by appending the following to `config/initializers/assets.rb`:
  ```ruby
  Rails.application.config.assets.precompile += %w( controllers/*.css controllers/*.js )
  ```

  7) Update `default_controller` of existing users in DB to use the new controller name

  8) Update existing role permissions in DB to use the new controller name


* Dummy application now uses an extended `Admin::Nodes` controller
  instead of the default `Releaf::Content::NodesController`

* `releaf_routes_for` helper has been renamed to `node_routes_for`.
* `node_class` param is now always added to generated node routes along with `node_id` and `locale`
* The signature of the old `Releaf::Content::Route.for` helper has changed
  and now it expects node model class name as the first argument.

  If it is still used directly somewhere in `routes.rb`
  instead of the now preferred `node_routes_for`, then it should be changed from

  ```ruby
  Releaf::Content::Route.for(TextPage).each do|route|
     ...
  end
  ```

  to

  ```ruby
  Releaf::Content::Route.for(Node, TextPage).each do|route|
     ...
  end
  ```

* Multiple node models and controllers are now supported.

  Node resource configuration can be overriden via `content.resources` key
  in `config/initializers/releaf.rb`

  There are three typical scenarios:

  1) Default configuration

  Node model is called `Node` and handled by `Releaf::Content::NodesController`

  Nothing needs to be changed for this to work
  except renaming `releaf_routes_for` to `node_routes_for` in `routes.rb`

  2) Custom node model and/or controller

  For example, if a model called `SomeOtherNode` needs to be used instead of `Node`
  and it will be handled in admin by `Admin::NodesController`, then the configuration
  looks as follows:

  ```ruby
  config.content.resources = { 'SomeOtherNode' => { controller: 'Admin::NodesController' } }
  ```

  3) Multiple per-site node models in separate content trees

  When a single application needs to handle multiple separate websites
  with separate content trees, multiple node models can be used.

  An example configuration would look as follows.

  In `config/initializers/releaf.rb`:

  ```ruby
  config.content.resources = {
    'Node' => {
      controller: 'Releaf::Content::NodesController',
      routing: {
        site: "main_site",
        constraints: { host: /^releaf\.local$/ }
      }
    },
    'OtherSite::OtherNode' => {
      controller: 'Admin::OtherSite::OtherNodesController',
      routing: {
        site: "other_site",
        constraints: { host: /^other\.releaf\.local$/ }
      }
    }
  }
  ```

  In `routes.rb`:

  ```ruby
  node_routing( Releaf::Content.routing ) do

    node_routes_for(HomePage) do
      get 'show', as: "home_page"
    end

    node_routes_for(TextPage) do
      get 'show'
    end

  end
  ```

  This configuration would mean that all `HomePage` and `TextPage` nodes
  with `Node` class would have their routes drawn
  constrained to `http:://releaf.local/` host name
  and all `HomePage` and `TextPage` nodes using `OtherSite::OtherNode` node class
  would only have routes for `http://other.releaf.local/` website.

  The drawn routes will have extra parameters `site` and `node_class` passed to them
  that can be used in the public website if needed. See `#node_class` and `#site`
  methods in `application_controller.rb` of Dummy application for example usage.

  Each node tree can have its own structure and content types. Add structure validations
  to specific node models as needed.

  If a node content type needs to only be available in a single site,
  the `node_routing` automation block can be omitted and the corresponding routes
  can be drawn for a specific node class and constrained manually:

  ```ruby
  constraints Releaf::Content.routing['OtherSite::OtherNode'][:constraints] do
    node_routes_for(ContactsController, node_class: 'OtherSite::OtherNode') do
      get 'show', as: "contacts_page"
    end
  end
  ```

  If multiple `node_routes_for` blocks are needed with the same `node_class` argument,
  they can be wrapped inside a `for_node_class` block.

  ```ruby
  for_node_class 'OtherSite::OtherNode' do

    node_routes_for(HomePage) do
      get 'show', as: "home_page"
    end

    node_routes_for(TextPage) do
      get 'show'
    end

  end
  ```

  is the same as

  ```
  node_routes_for(HomePage, node_class: 'OtherSite::OtherNode') do
    get 'show', as: "home_page"
  end

  node_routes_for(TextPage, node_class: 'OtherSite::OtherNode') do
    get 'show'
  end
  ```

### 2016.01.05
* Node#url has been renamed to Node#path.

### 2015.12.29
* Extra search fields should now be wrapped in a container with a "search-field" class using the search_field method of IndexBuilder unless a custom layout is needed.
* HTML classes "block", "clear" and "clear-inside" have been deprecated and will be removed soon. They are no longer used by releaf. Use `@include block-list;`, and `@include clear-inside;` in SASS instead.
* Custom input fields with text, email, password or number types now need to have a "text" class to be styled correctly.
* Main menu no longer has icons. You should remove all :icon keys from menu hash in config/initializers/releaf.rb
* Toolbox trigger now has a kebab icon and is located at the far right of rows in index views
* Toolbox items no longer have icons. You should pass nil as the icon argument to the button helper when creating custom toolbox items
* Gravatar image is no longer displayed in the user box in the header

### 2015.11.12
* `current_params` method removed from `Releaf::BaseController`. Is it
  recommended to simply use `request.query_parameters` instead.

### 2015.11.09
* Refactored Releaf node public route definition syntax.
  Old syntax:
  ```ruby
  Rails.application.routes.draw do
    Releaf::Content::Route.for(HomePage).each do |route|
      get route.params('home_pages#show')
    end
  end
  ```

  New equivalent:
  ```ruby
  Rails.application.routes.draw do
    releaf_routes_for(HomePage) do
      get 'show'
    end
  end
  ```

  ```releaf_routes_for``` accepts two parameters: node content class and
  optional options hash. By default ```releaf_routes_for``` routes requests to
  pluralized content class name controller (HomePage -> HomePagesController).
  It is possible to owerride default providing ```:controller``` option with
  string representation of controllers name (such as ```'text_pages```', which
  will route to ```TextPagesController```).
  Example:
  ```ruby
  releaf_routes_for(HomePage, controller: 'text_pages') do
    get 'show'
  end
  ```

  ```releaf_routes_for``` supports all simple route definition methos such as
  ```get```, ```put```, ```patch```, ```post```, ```delete``` etc.
  ```resources```, ```resource```, ```scope```, ```namespace``` however aren't
  supported and will cause unexpected behaviour (most likely an exception), if
  used.

  Old syntax is still supported, however it is advised to migrate to new syntex.

  Here are all possible examples of new syntax (Given node.url is ```/examples```):
  ```ruby
  releaf_routes_for(HomePage) do
    get 'index' # GET '/examples' => HomePagesController#index
    get ':id' # GET '/examples/12' => HomePagesController#show, id == '12'
    delete ':id' # DELETE '/examples/12' => HomePagesController#destroy, id == '12'
    get ':id/details', to: 'details#show' # GET '/examples/12/details' => DetailsController#show, id == '12'
  end

  releaf_routes_for(TextPage, controller: 'info_pages') do
    get 'index' # GET '/examples' => InfoPagesController#index
    delete 'text_pages#destroy' # DELETE '/examples' => TextPagesController#destroy
    get 'info', to: '#info' # GET '/examples/info' => InfoPagesController#info
    get 'full-info', to: 'advanced_info_pages#info' # GET '/examples/full-info' => AdvancedInfoPagesController#info
  end
  ```

  Naturally you can pass ```:as```, ```:constraints``` and other options supported by regular ```get```, ```put``` and other methods.

  General rules of thumb:
  1) to create route to default contrller and to url of node, then just create
    route with string target method name:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'index'
    end
    ```
  2) to create route to different controller, add ```:to``` option and specify
    controller and action:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'list', to: 'info_pages#index'
    end
    ```
  3) to create route with additonal url, that routes to default controller,
    don't specify controller controller in ```:to``` option:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'list', to: '#index'
    end
    ```
  4) To route to differnt contrller from node url, just specify controller and
    action as first argument:
    ```ruby
    releaf_routes_for(TextPage) do
      get 'info_pages#show'
    end
    ```
  5) to change default controller, pass ```:controller``` argument:
    ```ruby
    releaf_routes_for(TextPage, controller: 'info_pages') do
      get 'index'
    end
    ```

  Feel free to investigage
  [pull request](https://github.com/cubesystems/releaf/pull/246)
  and especially
  [routing tests](https://github.com/graudeejs/releaf/blob/05e1b7062e4bdc25e8457b338061b2e0bae76159/releaf-content/spec/routing/node_mapper_spec.rb)

### 2015.10.14
* `Releaf::Core::Application` and `Releaf::Core::Configuration` introduced
* From now all settings is available through `Releaf.application.config`
  instead of `Releaf`
* Releaf initalizer must be updated by changing `Releaf.setup do |conf|` to `Releaf.application.configure do` and
  replacing all `conf.` with `config.`
* change `conf.layout_builder = CustomLayoutBuilder``` to `config.layout_builder_class_name = 'CustomLayoutBuilder'`

### 2015.08.05
* Renamed `Releaf::TemplateFieldTypeMapper` to `Releaf::Core::TemplateFieldTypeMapper`
* Renamed `Releaf::AssetsResolver` to `Releaf::Core::AssetsResolver`
* Renamed `Releaf::ErrorFormatter` to `Releaf::Core::ErrorFormatter`
* Moved `Releaf::Responders` under `Releaf::Core` namespace

### 2015.08.04
* refactored `@searchable_fields`. Now you should override `#searchable_fields`
  method instead. By default searchable fields will be guessed with help of
  `Releaf::Core::DefaultSearchableFields`
* Renamed `Releaf::Search` to `Releaf::Core::Search`

### 2015.08.01
* Releaf::Builders::IndexBuilder has been refactored with following changes:
  - `search` method renamed to `search_block`
  - `extra_search` method renamed to `extra_search_block`
  - `pagination` method renamed to `pagination_block`
  - section header text and resources count translations renamed
* "global.admin" translation scope has been removed in favour of controller name scope

### 2015.07.23
* Releaf::ResourceFinder was refactored and renamed to Releaf::Search.
  If you used Releaf::ResourceFinder somewhere, you need to change
  ```ruby
  relation = Releaf::ResourceFinder.new(resource_class).search(parsed_query_params[:search], @searchable_fields, relation)
  ```
  to
  ```ruby
  relation = Releaf::Search.prepare(relation: relation, text: parsed_query_params[:search], fields: @searchable_fields)
  ```

### 2015.01.09
* Controller name scoped builders implemented.
  More there: http://cubesystems.github.io/releaf/documentation/builders.html#creation

### 2014.12.04
* BaseController 'resource_params' method renamed to 'permitted_params'

### 2014.09.15
* Releaf controllers now properly resolves namespaced classes
  For example Admin::Foo::BarsController previously would resolve to Bar class,
  now it will resolve to Foo::Bar class

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
