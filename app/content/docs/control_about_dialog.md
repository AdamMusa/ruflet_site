# AboutDialog

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

The standard about box: your app's name, version, icon and legal notice, with
a button that opens the open-source licenses page.

## Example

```ruby
about = about_dialog(
  application_name: "Field Notes",
  application_version: "2.1.0",
  application_icon: icon("menu_book"),
  application_legalese: "© 2026 Field Notes contributors",
  controls: [text("Notes that sync across your devices.")]
)

page.add(
  text_button(content: text("About"), on_click: ->(_event) { page.show_dialog(about) })
)
```

Show it with `page.show_dialog`, like any dialog, and close it with
`page.pop_dialog`.

## Properties

- `application_name`, `application_version` and `application_legalese` — Strings shown in the dialog.
- `application_icon` — a control, usually an `icon` or an `image`.
- `controls` — extra controls shown below the name and version.
- `view` — `"about"` (default) or `"licenses"`, which opens the licenses page directly.
- `modal` — when `true`, tapping outside does not close the dialog.
- `barrier_color` — the color behind the dialog.

## Events

- `on_dismiss` — the dialog was closed.
