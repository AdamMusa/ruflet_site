# CupertinoSegmentedButton

A row of connected segments for picking one option by index. It builds the same
`SegmentedButton` control as [`segmented_button`](/docs/control-segmented-button):
on iOS and macOS the client draws the iOS segmented control, elsewhere a
Material segmented button.

## Example

```ruby
choice = text(value: "Map")
labels = %w[Map Transit Satellite]
page.add(
  column(
    children: [
      cupertino_segmented_button(
        labels.map { |label| text(label) },
        selected_index: 0,
        on_change: ->(event) { page.update(choice, value: labels[event.data.to_i]) }
      ),
      choice
    ]
  )
)
```

## Common properties

- `controls` — one control per segment, at least two; the first positional argument sets them
- `selected_index` — defaults to `0`
- `selected_color` / `unselected_color` / `border_color` / `click_color`
- `disabled_color` / `disabled_text_color`
- `padding`
- `on_change` — `event.data` is the index of the chosen segment

## Usage

The client writes the chosen index to `selected_index` before it sends
`on_change`, so `event.data` and `event.control.props["selected_index"]` hold
the same Integer. `event.control.selected_index` returns it too; with 0.0.23 it
raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`cupertino_segmented_button` raises `ArgumentError` unless it has at least two
visible segments, and `IndexError` when `selected_index` is out of range.

The color properties style the iOS control only. On Android, web, Windows and
Linux the Material button ignores them, and `padding` makes it fill the
available width, inset by that padding. For
the sliding iOS style, use
[`cupertino_sliding_segmented_button`](/docs/control-cupertino-sliding-segmented-button).
