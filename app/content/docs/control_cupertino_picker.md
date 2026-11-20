# CupertinoPicker

An iOS-style scrolling wheel for picking one item. `cupertino_picker` builds the
same `Picker` control as [`picker`](/docs/control-picker) and sends the iOS
wheel defaults: `item_extent: 32`, `diameter_ratio: 1.07`, `squeeze: 1.45`,
`magnification: 1.0`, `off_axis_fraction: 0.0`, `use_magnifier: false`,
`looping: false` and `selected_index: 0`. On Android, web, Windows and Linux
the client draws a dropdown button that lists the items instead.

## Example

```ruby
fruits = %w[Apple Banana Cherry Grape Mango]
chosen = text(value: "Apple")
page.add(
  column(
    children: [
      cupertino_picker(
        fruits.map { |fruit| text(fruit) },
        height: 160,
        item_extent: 36,
        looping: true,
        use_magnifier: true,
        magnification: 1.2,
        on_change: ->(event) { page.update(chosen, value: fruits[event.data.to_i]) }
      ),
      chosen
    ]
  )
)
```

## Common properties

- `controls` — one control per row; the first positional argument sets them
- `selected_index` — the row the wheel starts at (default 0)
- `item_extent` — height of each row, in logical pixels
- `looping` — let the wheel wrap around
- `use_magnifier` / `magnification` — enlarge the row in the selection band
- `diameter_ratio` / `squeeze` / `off_axis_fraction` — the wheel's curve, density and tilt
- `selection_overlay` / `default_selection_overlay_bgcolor` — what marks the selected row
- `bgcolor`
- `on_change` — `event.data` is the index of the row the wheel settled on

## Usage

The wheel sends `on_change` each time it settles on another row while the user
scrolls, after it writes the index to `selected_index`. Give the picker a
`height`: the wheel fills the height it is given.

`event.control.selected_index` returns the same index as
`props["selected_index"]`; with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

The wheel properties apply on iOS and macOS only. On Android, web, Windows and
Linux the dropdown reads only `controls`, `selected_index`, `on_change` and the
common layout properties.
