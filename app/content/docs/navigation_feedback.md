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
    text_button(content: text("Cancel"), on_click: ->(_event) { page.pop_dialog }),
    filled_button(content: text("Delete"), on_click: ->(_event) { delete_item })
  ]
)

page.show_dialog(dialog)
```

Use `page.pop_dialog` to close the latest open dialog.

## Bottom sheets

```ruby
page.show_bottom_sheet(
  bottom_sheet(content: container(padding: 24, content: text("Sheet content")))
)
```

## Snackbars

```ruby
page.show_snack_bar(
  snack_bar(content: text("Changes saved"))
)
```

## Banners

```ruby
page.show_banner(
  banner(
    content: text("You are offline"),
    actions: [text_button(content: text("Dismiss"), on_click: ->(_event) { page.close_banner })]
  )
)
```

The `show_dialog`, `show_snack_bar`, `show_bottom_sheet`, and `show_banner`
methods all mount the control and open it. (Assigning `page.snack_bar`,
`page.bottom_sheet`, or `page.dialog` directly also works, but the control must
be built with `open: true` to display.)

Use transient feedback for action results. Keep validation errors near the
affected input when the user needs to correct them.
