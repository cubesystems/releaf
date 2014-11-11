---
title: Base objects & admin controllers
weight: 2
subitems:
  -
    title: Field name and admin UI relation
    anchor: field-name
  -
    title: Field database column type
    anchor: field-database
---

## Base objects & admin controllers

### Field name and admin UI relation {#field-name}
*_id - relation input

(thumbnail|image|photo|picture|avatar|logo|icon)_uid - image upload

*_uid - file upload

password - password

*_link, link, *_url, url - url

### Field database column type and admin UI relation {#field-database}


boolean - checkbox

text - textarea. If field have name with "_html" postfix, then input type will by richtext (tinymce).

datetime - datetime

date - date

time - time

string - text
