# CupertinoSlidingSegmentedButton

A segmented control whose selection slides from segment to segment, as in iOS
settings screens. It builds a `SegmentedButton` control; elsewhere than iOS and
macOS the client draws a Material segmented button.

## Example

```ruby
choice = text(value: "Day")
labels = %w[Day Week Month]
page.add(
  column(
    children: [
      cupertino_sliding_segmented_button(
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
- `proportional_width` — on iOS and macOS, size each segment to its content instead of equally; the 0.0.23 client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `bgcolor` / `thumb_color` — on iOS and macOS, the colors of the track and of the sliding thumb; the 0.0.23 client ignores them. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `on_change` — `event.data` is the index of the chosen segment

## Usage

Like `cupertino_segmented_button`, it needs at least two visible segments and
an in-range `selected_index`. The sliding look on iOS and macOS comes from the
`sliding` flag this helper sends. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
With 0.0.23 it renders as the standard iOS segmented control.
