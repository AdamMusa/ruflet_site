# View

One screen of a route-based app. `page.views` holds a stack of views: the
client shows the last one, with a back button and the back gesture that
return to the one before. Each view has its own app bar, controls, drawers,
bottom bars and floating action button.

## Example

```ruby
render = lambda do
  stack = [
    view(
      route: "/",
      appbar: app_bar(title: text("Home")),
      controls: [
        text("Welcome"),
        button("Open settings", on_click: ->(_event) { page.go("/settings") })
      ]
    )
  ]
  if page.route == "/settings"
    stack << view(
      route: "/settings",
      appbar: app_bar(title: text("Settings")),
      padding: 24,
      controls: [text("Notifications are on")]
    )
  end
  page.views = stack
  page.update
end

page.on_route_change = ->(_event) { render.call }
page.on_view_pop = ->(_event) { page.go("/") }
render.call
```

## Common properties

- `route` — the view's route, such as `"/settings"`
- `controls` — the body's controls, top to bottom; the first positional argument sets them
- `appbar` / `navigation_bar` / `bottom_appbar` / `floating_action_button` / `drawer` / `end_drawer` — the view's chrome
- `padding` (default 10) / `spacing` (default 10) / `vertical_alignment` / `horizontal_alignment` / `bgcolor`
- `scroll` — make the body scroll, for example `"auto"`; `on_scroll` reports the position
- `can_pop` / `on_confirm_pop` — ask before the user leaves the view
- `fullscreen_dialog` — open the view as a full-screen dialog
- `decoration` / `foreground_decoration` — a box decoration behind or over the whole view
- `bottom_sheet` — a control pinned to the bottom of the view. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `on_refresh` / `on_end_reached` and the `refresh_*` keywords — pull to refresh and load more. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Without `page.views`, the page has one implicit view: `page.appbar`,
`page.navigation_bar`, `page.drawer`, `page.floating_action_button` and the
other page properties set its chrome, and `page.add` adds to its body. Once
`page.views` holds views, those page properties no longer apply; give each
`view` its own `appbar:` and the rest, as above.

To ask before the user leaves a view, set `can_pop: false` and answer
`on_confirm_pop` with `page.invoke`. The view stays when the answer is `false`
or when no answer comes:

```ruby
editor = view(
  route: "/edit",
  can_pop: false,
  appbar: app_bar(title: text("Edit note")),
  controls: [text_field(label: "Note")],
  on_confirm_pop: ->(event) { page.invoke(event.control, "confirm_pop", args: { "should_pop" => true }) }
)
page.views = [view(route: "/", controls: [text("Notes")]), editor]
page.update
```

`floating_action_button_location` takes Flutter's names in camel case, such
as `"endFloat"` (default), `"centerFloat"` or `"centerDocked"`; the 0.0.23
client does not read the underscore spelling. On iOS and macOS a docked
location floats above the navigation bar, which has no notch.

`services` is accepted but the client does not read it; register services
with `page.services` or `page.service(...)`.
