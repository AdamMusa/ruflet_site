# ProgressBar

A horizontal progress indicator. Leave `value` unset for an indeterminate,
animated bar, or set it between `0.0` and `1.0` to show how far a task has got.
Use [`progress_ring`](/docs/control-progress-ring) for the circular version.

## Example

```ruby
upload = progress_bar(value: 0.0, bar_height: 8, border_radius: 4, width: 240)
step = 0
page.add(
  column(
    children: [
      progress_bar(width: 240),
      upload,
      button("Advance", on_click: ->(_event) {
        step = [step + 1, 4].min
        page.update(upload, value: step / 4.0)
      })
    ]
  )
)
```

## Common properties

- `value` — `nil` for indeterminate, or `0.0` to `1.0`
- `bar_height` — thickness of the bar
- `color` / `bgcolor` — the filled part and the track
- `border_radius`
- `width`
- `semantics_label` / `semantics_value` — what screen readers announce

## Usage

Keep the bar in a variable and change only `value` with `page.update` as the
work progresses, as the example does. Show an indeterminate bar while the
total amount of work is still unknown. On iOS and macOS an indeterminate bar
shows a spinning activity indicator instead of a moving bar.
