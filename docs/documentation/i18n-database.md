---
title: I18n database backend
weight: 2000
---

# I18n database backend

The `Releaf::I18nDatabase` component provides a mechanism for storing I18n translation texts in a database.

Instead of having to edit dictionary YAML files, an administrator can edit all I18n text strings within a browser in the Releaf's administration panel.

* [Installation](#installation)
* [Using translations](#usage)
* [Editing translations](#editing)
* [Exporting and importing translations](#export-import)
* [Handling missing translations](#missing)

## Installation {#installation}

The `Releaf::I18nDatabase` component comes already enabled by default with the standard Releaf installation, and nothing else needs to be done to use it.

If it has been removed, it can be enabled manually in the [configuration file](../installation/configuration/).

The `config/initializers/releaf.rb` file should have `Releaf::I18nDatabase` included in the `config.components` array.

The `config.menu` array should have an entry pointing to the translations controller, e.g.:

```ruby
config.menu = [
  ...
  { controller: 'releaf/i18n_database/translations }
  ...
]
```

Remove these if you do not need this component.

If installing this component manually, the database migration to generate the needed tables can be taken from the [Releaf installer template](https://github.com/cubesystems/releaf/blob/master/releaf-core/lib/generators/releaf/templates/migrations/create_releaf_translations.rb).


## Using translations {#usage}

Once enabled, the component works transparently.

All calls to `I18n.translate`, including `I18n.t` and `t` aliases, automatically use the database store to fetch the texts.

All translations get preloaded in memory, so a separate database query is not made for each call to `I18n.translate`.

By default, requesting a new translation automatically creates its key in the database, so there is no need to define the translation keys beforehand. See the section about [missing translations](#missing) for more on this.

If a translation text has not been entered in the requested locale, the returned string is a humanized version of the requested key.


## Editing translations {#editing}

The translations can be edited by any administrator who has access to the translations controller.

Clicking on the translations item in Releaf's menu opens the index view with a table listing all translations.

The table has a key column and separate value columns for each of the available locales.

The translation keys are linearized strings representing the translation scope structure used.

If a translation is invoked like this:

```ruby
I18n.translate('books', scope: 'admin.controllers')
```

then its key in the admin panel will be

```
admin.controllers.books
```

Clicking the "Edit" button will open the same table in an editable view.

If there are many translations, it is recommended to first filter them out by using the search box at the top of the Index view, so that only the needed translations are displayed.

The text entered in the search form is matched against both keys and values.


## Exporting and importing translations {#export-import}

Translation texts can be exported and imported in batches using the `.xlsx` file format.

This is useful for sending the texts to a translator who does not have access to the administration panel, and for transferring the entered texts between different application environments, e.g., from a staging server to production.

When exporting, only the currently filtered translation view is exported, so it is possible to export only a specific part of the texts.

When importing, the texts from the spreadsheet are first presented to the user for approval, so that the administrator can verify that the data about to be imported is correct before saving.


## Handling missing translations {#missing}

By default, when a translation key is requested that has not been defined, it will be automatically inserted in the database with blank values in all locales.

This greatly reduces the amount of work for the programmer, allowing to simply use a new translation key in the code without having to define it anywhere else.

If this behaviour is unwanted, the automatic creation of missing keys can be disabled either globally or for a specific translation call.

To prevent the creation of a single missing key, pass `false` as the `create_missing` option:

```ruby
I18n.translate('something', create_missing: false)
```

To disable the creation of missing keys for the whole application, add the following to `config/initializers/releaf.rb` file:

```ruby
config.create_missing_translations = false
```


{% comment %} :TODO: describe count / pluralization {% endcomment %}

{% comment %} :TODO: describe variables {% endcomment %}

{% comment %} :TODO: implement and describe reasonable seeding {% endcomment %}

{% comment %} :TODO: describe scope lookup for missing translations (using ancestor scopes) {% endcomment %}


