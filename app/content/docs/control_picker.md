# Picker

Picks one item from a short list. On iOS and macOS the client draws a
scrolling wheel; on Android, Windows and Linux a dropdown button that
lists the items. Each item is a control, usually a `text`.
[`cupertino_picker`](/docs/control-cupertino-picker) builds the same control
with the iOS wheel defaults. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
sizes = %w[Small Medium Large]
chosen = text(value: "Size: Medium")
page.add(
  column(
    children: [
      picker(
        sizes.map { |size| text(size) },
        selected_index: 1,
        height: 150,
        on_change: ->(event) { page.update(chosen, value: "Size: #{sizes[event.data.to_i]}") }
      ),
      chosen
    ]
  )
)
```

## Common properties

- `controls` — one control per item; the first positional argument sets them
- `selected_index` — the selected item, from 0 (default)
- `on_change` — `event.data` is the index of the picked item
- `height` — the wheel's height on iOS and macOS

## Usage

The client writes the new index to `selected_index` before it sends
`on_change`, so `event.data` and `event.control.props["selected_index"]` hold
the same Integer. On iOS and macOS the wheel sends `on_change` each time it
settles on another item while the user scrolls; the dropdown sends it once per
pick.

`event.control.selected_index` returns the same index as
`props["selected_index"]`; with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS the wheel fills the height it is given, so give it a
`height` inside a `column`, as above.

## Platform differences

The wheel's look applies on iOS and macOS only: `item_extent`,
`diameter_ratio`, `magnification` with `use_magnifier`, `squeeze`,
`off_axis_fraction`, `looping`, `selection_overlay`,
`default_selection_overlay_bgcolor` and `bgcolor`. On Android, Windows and
Linux a picker with no items, or with a `selected_index` outside them, draws an
error box instead of the dropdown.
