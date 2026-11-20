# NavigationDrawer

A panel that slides in from the side with the app's main destinations. Assign
it to `page.drawer` (or `page.end_drawer` for the other side), or to a
view's `drawer:` when the app uses `page.views`. On Android,
web, Windows and Linux the app bar then shows a menu button that opens it, and
the user can also swipe it in from the edge.

## Example

```ruby
folders = %w[Inbox Sent Trash]
folder = text(value: "Inbox", size: 20)
page.appbar = app_bar(title: text("Mail"))
page.drawer = navigation_drawer(
  [
    navigation_drawer_destination(icon: "inbox", label: "Inbox"),
    navigation_drawer_destination(icon: "send", label: "Sent"),
    navigation_drawer_destination(icon: "delete", label: "Trash")
  ],
  selected_index: 0,
  on_change: ->(event) { page.update(folder, value: folders[event.data.to_i]) }
)
page.add(folder)
```

## Common properties

- `controls` — `navigation_drawer_destination(icon:, label:)` entries, plus any other controls such as a heading or a `divider`; the first positional argument sets them
- `selected_index` — the highlighted destination
- `bgcolor` / `elevation` / `shadow_color`
- `indicator_color` / `indicator_shape` — the highlight behind the selected destination
- `tile_padding`
- `on_change` — `event.data` is the index of the chosen destination
- `on_dismiss` — the drawer was closed

## Usage

On iOS and macOS the drawer uses `controls`, `selected_index`, `bgcolor`,
`indicator_color` and `tile_padding`. `elevation`, `shadow_color` and
`indicator_shape` apply on Android, web, Windows and Linux only. On iOS and
macOS, `selected_index` and `event.data` count every entry of `controls`,
headings and dividers included, while the other platforms count destinations
only. The two agree when no heading or divider comes before a destination, as
in the example. `on_dismiss` fires whenever the drawer closes.

### Open and close the drawer from code

Give the drawer to a view in `page.views`, and call `page.invoke` with that
view and `"show_drawer"` or `"close_drawer"` (`"show_end_drawer"` and
`"close_end_drawer"` for its `end_drawer`). This works with 0.0.23 and on
every platform. Picking a destination does not close the drawer, so close it
in `on_change`:

```ruby
folder = text(value: "Inbox", size: 20)
home = view(
  route: "/",
  appbar: app_bar(title: text("Mail")),
  drawer: navigation_drawer(
    [
      navigation_drawer_destination(icon: "inbox", label: "Inbox"),
      navigation_drawer_destination(icon: "send", label: "Sent")
    ],
    on_change: ->(event) {
      page.update(folder, value: %w[Inbox Sent][event.data.to_i])
      page.invoke(home, "close_drawer")
    }
  ),
  controls: [folder, button("Open folders", on_click: ->(_event) { page.invoke(home, "show_drawer") })]
)
page.views = [home]
page.update
```

On iOS and macOS the app bar has no menu button and there is no edge swipe,
so the drawer opens only from code. With 0.0.23 that means a view's drawer
opened with `page.invoke`, as above.

### Open and close `page.drawer`

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client answers these calls with an "Unknown Page method" error, and nothing opens.

`page.show_drawer` and `page.close_drawer` open and close the start drawer;
`page.show_end_drawer` and `page.close_end_drawer` do the same for
`page.end_drawer`. With `page.views`, they act on the drawers of the top view.

```ruby
folder = text(value: "Inbox", size: 20)
page.drawer = navigation_drawer(
  [
    navigation_drawer_destination(icon: "inbox", label: "Inbox"),
    navigation_drawer_destination(icon: "send", label: "Sent")
  ],
  on_change: ->(event) {
    page.update(folder, value: %w[Inbox Sent][event.data.to_i])
    page.close_drawer
  }
)
page.add(column(children: [folder, button("Open folders", on_click: ->(_event) { page.show_drawer })]))
```
