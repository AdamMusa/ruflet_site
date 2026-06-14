# Navigation and Feedback

Ruflet supports route-driven view stacks, navigation controls, dialogs, bottom
sheets, snackbars, and banners.

## Routes and views

```ruby
page.on_route_change = ->(_event) { render_route(page) }
page.on_view_pop = ->(_event) {
  page.views.pop
  page.go(page.views.last&.route || "/")
}

page.go("/")
```

Build a stack by assigning `page.views`:

```ruby
page.views = [
  view(route: "/", controls: [text("Home")]),
  view(route: "/settings", controls: [text("Settings")])
]
page.update
```

Navigation controls such as `navigation_bar`, `navigation_rail`, `tabs`, and
`navigation_drawer` can change application state or call `page.go`.

## Dialogs

```ruby
dialog = alert_dialog(
  open: false,
  title: text("Delete item?"),
  actions: [
    text_button(content: text("Cancel"), on_click: ->(_event) { page.close_dialog(dialog) }),
    filled_button(content: text("Delete"), on_click: ->(_event) { delete_item })
  ]
)

page.show_dialog(dialog)
```

Use `page.close_dialog(dialog)` to close a specific dialog or
`page.pop_dialog` to close the latest open dialog.

## Bottom sheets

Assign a bottom sheet through the page API:

```ruby
page.bottom_sheet = bottom_sheet(
  open: true,
  content: container(padding: 24, content: text("Sheet content"))
)
```

## Snackbars

```ruby
page.snack_bar = snack_bar(
  open: true,
  content: text("Changes saved")
)
```

Use transient feedback for action results. Keep validation errors near the
affected input when the user needs to correct them.
