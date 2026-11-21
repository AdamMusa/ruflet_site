# AppBar

The bar across the top of a page, with a title, a leading button and action
buttons. On Android, web, Windows and Linux it is a Material app bar; on iOS
and macOS the client draws the iOS navigation bar instead.

## Example

```ruby
status = text(value: "Inbox")
page.appbar = app_bar(
  title: text("Inbox"),
  bgcolor: "#0f766e",
  color: :white,
  actions: [
    icon_button("search", tooltip: "Search", on_click: ->(_event) { page.update(status, value: "Searching") }),
    icon_button("more_vert", tooltip: "More", on_click: ->(_event) { page.update(status, value: "More") })
  ]
)
page.add(status)
```

## Common properties

- `title` — a string or a control, usually `text(...)`
- `leading` — a control at the start, usually an `icon_button`; without it the bar adds a back button when `automatically_imply_leading` (default `true`) allows, or, on Android, web, Windows and Linux, a menu button when the page has a `drawer`
- `actions` — controls at the end, usually `icon_button`s
- `bgcolor`
- `color` — the title and icon color (Android, web, Windows and Linux only)
- `center_title` / `title_spacing` / `toolbar_height` / `elevation` (Android, web, Windows and Linux only)
- `large` — a large title below the bar; on Android, web, Windows and Linux it needs the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Assign the bar with `page.appbar = app_bar(...)`. When the app keeps a stack
in `page.views`, each `view` shows its own bar instead: pass it as
`view(route: "/settings", appbar: app_bar(...))`.

On iOS and macOS the title is always centered, the bar is flat and has the
fixed iOS height, and `actions` sit in one row at the trailing edge. These
keywords shape the Material bar only: `color`, `center_title`, `elevation`,
`elevation_on_scroll`, `shadow_color`, `shape`, `toolbar_height`,
`toolbar_opacity`, `leading_width`, `title_spacing`, `title_text_style`,
`toolbar_text_style`, `actions_padding`, `force_material_transparency`,
`secondary`, `exclude_header_semantics` and `clip_behavior`.

These shape the iOS bar only: `previous_page_title` (the back button's label),
`border`, `padding`, `brightness`, `automatically_imply_title`,
`transition_between_routes` and `automatic_background_visibility`.
`enable_background_filter_blur` turns off the blur under a translucent iOS
bar; the 0.0.23 client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

For a bar that only iOS uses, [`cupertino_app_bar`](/docs/control-cupertino-app-bar)
takes the iOS keywords and a single `trailing` control. `trailing` also works
on `app_bar`, where it replaces `actions`; on Android, web, Windows and Linux
it needs the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
