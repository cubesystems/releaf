---
title: Richtext editor
weight: 2
---

## Editor
To have auto-enabled richtext editor (TinyMCE) attribute name must end with _html prefix. Example: text_html will be rendered as richtext UI.

## Attachments (files, images)
To enable file uploading:

1. add `include Releaf::Attachments` to your controller
2. add attachmentable concern to your resource route, example: `releaf_resources :books, concerns: :attachmentable`
