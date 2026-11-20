# DraggableScrollableSheet

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A maps-style sheet that the user drags between a small and a large size, with
a scrolling list inside. It fills its parent, so place it in a `stack` over
the main content. For a modal panel, use
[`bottom_sheet`](/docs/control-bottom-sheet) instead.

## Example

```ruby
places = ["Cafe Aroma", "City Library", "Riverside Park", "Night Market", "Old Town Hall"]
extent = text(value: "Sheet at 30%")

sheet = draggable_scrollable_sheet(
  places.map { |name| list_tile(title: text(name)) },
  initial_child_size: 0.3,
  min_child_size: 0.15,
  max_child_size: 0.9,
  snap: true,
  snap_sizes: [0.5],
  header: text("Nearby places"),
  on_extent_change: ->(event) {
    page.update(extent, value: "Sheet at #{(event.data["extent"] * 100).round}%")
  }
)

page.add(
  stack(
    expand: true,
    children: [
      container(
        expand: true,
        padding: 16,
        bgcolor: :surface_container_high,
        content: column(
          children: [
            extent,
            text_button(content: text("Expand"), on_click: ->(_event) { sheet.animate_to(0.9) })
          ]
        )
      ),
      sheet
    ]
  )
)
```

Give the sheet's rows as the first argument, as `children:`, or in a block.

## Properties

- `initial_child_size`, `min_child_size` and `max_child_size` — fractions of the parent's height (defaults 0.5, 0.25 and 1.0).
- `snap` and `snap_sizes` — settle at the minimum, the maximum or a listed size after a drag.
- `snap_animation_duration` — how long snapping takes.
- `should_close_on_min_extent` — whether dragging the sheet to its minimum size closes an enclosing modal sheet (default `true`).
- `header` — a control pinned above the rows, below the drag handle.
- `show_drag_handle` — draw the drag handle (default `true`).
- `padding` and `spacing` — space around and between the rows.
- `bgcolor`, `elevation` and `border_radius` — the sheet surface. `elevation` applies on Android, web, Windows and Linux only.
- `extent_change_interval` — the minimum milliseconds between two `on_extent_change` events (default 50).

## Events and methods

- `on_extent_change` — the sheet size changed. `event.data` has `"extent"`, `"min"` and `"max"`, as fractions.
- `animate_to(size, duration: 300, curve: "easeOut")` — animate the mounted sheet to a fraction of its parent's height.
- `jump_to(size)` — move the mounted sheet at once.
