# NavigationRail

A vertical bar of destinations for tablet and desktop layouts, where a bottom
[`navigation_bar`](/docs/control-navigation-bar) would waste width. Place it at
the start of a `row` that fills the page.

## Example

```ruby
sections = %w[Home Library Settings]
heading = text(value: "Home", size: 24)
rail = navigation_rail(
  selected_index: 0,
  label_type: "all",
  destinations: [
    navigation_rail_destination(icon: "home", label: "Home"),
    navigation_rail_destination(icon: "bookmarks", label: "Library"),
    navigation_rail_destination(icon: "settings", label: "Settings")
  ],
  on_change: ->(event) { page.update(heading, value: sections[event.data.to_i]) }
)
page.add(
  row(
    expand: true,
    children: [rail, vertical_divider(width: 1), column(expand: true, children: [heading])]
  )
)
```

## Common properties

- `destinations` — `navigation_rail_destination(icon:, label:, selected_icon:)` entries
- `selected_index`
- `label_type` — `"all"`, `"selected"` or `"none"`
- `extended` — show labels beside the icons; `min_extended_width` sets that width
- `leading` / `trailing` — controls above and below the destinations, such as a FAB
- `group_alignment` — `-1.0` (top) to `1.0` (bottom)
- `bgcolor` / `elevation` / `indicator_color` / `indicator_shape`
- `on_change` — `event.data` is the index of the chosen destination

## Usage

The rail needs a bounded height. Put it in a `row` with `expand: true`, as
above, so it fills the page from top to bottom. When `extended` is true, each
label sits beside its icon and `label_type` is ignored.
