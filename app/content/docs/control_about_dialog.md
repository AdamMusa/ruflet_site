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

- `application_name`, `application_version` and `application_legalese` — Strings shown in the dialog. Without `application_name` the dialog uses the app's window title.
- `application_icon` — a control, usually an `icon` or an `image`.
- `controls` — extra controls shown below the name and version.
- `view` — `"about"` (default) or `"licenses"`, which opens the licenses page directly, as a full page.
- `modal` — when `true`, tapping outside does not close the dialog.
- `barrier_color` — the color behind the dialog.

The licenses page lists the licenses of the packages built into the client.
It opens from the dialog's licenses button or with `view: "licenses"`, and it
closes together with the dialog. It has no backdrop, so `modal` and
`barrier_color` do not apply to it.

## Events

- `on_dismiss` — the dialog or the licenses page was closed, by the user or by your code.

## Platform differences

On Android, web, Windows and Linux the client shows the Material about dialog,
with "View licenses" and "Close" buttons. On iOS and macOS it shows an iOS
alert titled with the name and version, with the icon, the legal notice and
`controls` below it, and "View Licenses" and "Close" actions; the licenses
page is the iOS one.
