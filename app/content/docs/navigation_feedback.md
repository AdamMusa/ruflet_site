# Navigation and Feedback

Ruflet supports route-driven view stacks, navigation controls, dialogs, bottom
sheets, snackbars, and banners.

## Routes and views

A route-based app rebuilds `page.views` from `page.route` whenever the route
changes. The client shows the last [`view`](/docs/control-view) of the stack,
with a back button and the back gesture; going back sends `on_view_pop`, and
the app pops the view and goes to the route of the one below:

```ruby
render_route = lambda do
  stack = [
    view(
      route: "/",
      appbar: app_bar(title: text("Home")),
      controls: [button("Open settings", on_click: ->(_event) { page.go("/settings") })]
    )
  ]
  if page.route == "/settings"
    stack << view(route: "/settings", appbar: app_bar(title: text("Settings")), controls: [text("Settings")])
  end
  page.views = stack
  page.update
end

page.on_route_change = ->(_event) { render_route.call }
page.on_view_pop = ->(_event) {
  page.views.pop
  top = page.views.last
  page.go(top ? top.props["route"] : "/")
}
render_route.call
```

You can also build a stack directly by assigning `page.views`:

```ruby
page.views = [
  view(route: "/", controls: [text("Home")]),
  view(route: "/settings", controls: [text("Settings")])
]
page.update
```

## Navigation controls

These controls report the user's pick in `on_change`, with the index of the
destination or tab in `event.data`. Change what the page shows in the handler,
or call `page.go` in a route-based app:

- [`navigation_bar`](/docs/control-navigation-bar): the bar of two to five
  destinations along the bottom; the iOS tab bar on iOS and macOS.
- [`navigation_rail`](/docs/control-navigation-rail): a vertical strip of
  destinations beside the content, for wide layouts.
- [`navigation_drawer`](/docs/control-navigation-drawer): a panel that slides
  in from the side. On Android, web, Windows and Linux the app bar's menu button
  opens it; its page shows how to open it from code on every platform.
- [`tabs`](/docs/control-tabs) with a `tab_bar` and a `tab_bar_view`: tabs
  that switch sections inside one screen.

Two more kinds of control move the user around:

- [`app_bar`](/docs/control-app-bar): the bar at the top of a page or view, with
  a title, a back or menu button and `actions`.
- [`popup_menu_button`](/docs/control-popup-menu-button),
  [`menu_bar`](/docs/control-menu-bar) and
  [`context_menu`](/docs/control-context-menu): menus of commands, where each
  entry runs its own `on_click`.

## Dialogs

```ruby
items = text("3 items")
dialog = alert_dialog(
  title: text("Delete item?"),
  actions: [
    text_button(content: text("Cancel"), on_click: ->(_event) { page.pop_dialog }),
    filled_button(content: text("Delete"), on_click: ->(_event) {
      page.pop_dialog
      page.update(items, value: "2 items")
    })
  ]
)
page.add(column(children: [items, button("Delete an item", on_click: ->(_event) { page.show_dialog(dialog) })]))
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
