---
title: Settings
weight: 6
---

## Settings

Releaf uses "rails-settings-cached" gem for simple key/value settings permanent storing.

### Read/write
It's recommended to add some prefix to setting key, so instead of "email.from_address" better key name will be "myapp.email.from_address".

To write setting:
`Releaf::Settings["myapp.email.from_address"] = "noreply@example.com"`

To read:
`Releaf::Settings["myapp.email.from_address"]`

### Default values
For default values create "config/initializers/default_settings.rb" with content like:

```
Releaf::Settings.register([
  {key: "myapp.email.from_address", default: "noreply@example.com", description: "From email address"},
  {key: "myapp.email.from_name", default: "John Deer", description: "From email name"},
])
```

### UI
To enable simple controller for changing existing Releaf::Settings values, make following changes in releaf initializer:

* Add "Releaf::Core::SettingsUI" to releaf components definition:
```
config.components = [Releaf::Core::SettingsUI]
```
* Add "releaf/core/controller" to releaf menu definition:
```
    {
      :controller => "releaf/core/settings",
      :icon => 'cog',
    },
```
