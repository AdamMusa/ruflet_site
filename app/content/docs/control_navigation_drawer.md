# NavigationDrawer

A panel that slides in from the side with the app's main destinations. Assign
it to `page.drawer` (or `page.end_drawer` for the other side) and open it with
`page.show_drawer`.

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
  on_change: ->(event) {
    page.update(folder, value: folders[event.data.to_i])
    page.close_drawer
  }
)
page.add(
  column(
    children: [
      folder,
      button("Open folders", on_click: ->(_event) { page.show_drawer })
    ]
  )
)
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

`page.show_drawer` and `page.close_drawer` open and close the start drawer;
`page.show_end_drawer` and `page.close_end_drawer` do the same for
`page.end_drawer`. Close the drawer in `on_change` once the user has picked a
destination, as above.

On iOS and macOS the drawer uses `controls`, `selected_index`, `bgcolor`,
`indicator_color` and `tile_padding`. `elevation`, `shadow_color` and
`indicator_shape` apply on Android, web, Windows and Linux only. On iOS and
macOS, `selected_index` and `event.data` count every entry of `controls`,
headings and dividers included, while the other platforms count destinations
only. The two agree when no heading or divider comes before a destination, as
in the example.
