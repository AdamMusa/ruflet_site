# GridView

Display repeated content in a tiled layout.

## Example

```ruby
grid_view(
  runs_count: 2,
  spacing: 8,
  run_spacing: 8,
  children: [
    text(value: "A"),
    text(value: "B"),
    text(value: "C"),
    text(value: "D")
  ]
)
```

## Common properties

- `runs_count` — number of columns (rows for a horizontal grid), default 1
- `max_extent` — instead of a fixed count, the largest cell width; the grid fits as many columns as the width allows
- `children`
- `spacing` — space between rows of cells (default 10)
- `run_spacing` — space between columns of cells (default 10)
- `child_aspect_ratio` — width-to-height ratio of each cell (default 1, square)
- `horizontal`, `reverse`, `padding`
- `expand`

## Usage

```ruby
items = [{ name: "Apples" }, { name: "Bread" }, { name: "Cheese" }, { name: "Dates" }, { name: "Eggs" }]

grid_view(
  runs_count: 3,
  spacing: 12,
  children: items.map { |item| text(value: item[:name]) }
)
```

A photo grid that adapts its column count to the window, with cells wider than
tall:

```ruby
photos = (10..39).map { |id| "https://picsum.photos/id/#{id}/400/300" }

page.add(
  grid_view(
    photos.map { |src| image(src, fit: "cover", border_radius: 8) },
    max_extent: 200,
    child_aspect_ratio: 4 / 3.0,
    spacing: 8,
    run_spacing: 8,
    padding: 8,
    expand: true
  )
)
```

Cells are built as they scroll into view (`build_controls_on_demand`, on by
default). `on_scroll` reports the position in `event.data` with the same keys as
[`list_view`](/docs/control-list-view#scroll-events).

## Refreshing and loading more

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 these keywords raise ArgumentError (unknown keyword) and `scroll_to` does nothing.

`on_refresh`, `on_end_reached`, `keyboard_dismiss_behavior` and `scroll_to`
work as on `list_view`; see [Controls and Layout](/docs/controls-and-layout#scrolling).
Pull to refresh needs a vertical grid that is not reversed.
`refresh_bgcolor` and `refresh_displacement` apply on Android, web, Windows and
Linux only; `refresh_trigger_distance` on iOS and macOS only.

## Notes

- Use `children:` for the tiles, consistent with `column`, `row`, and
  `list_view`.
