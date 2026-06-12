# ProgressRing

A circular progress indicator. Leave `value` unset for an indeterminate spinner,
or set it (0.0–1.0) for determinate progress. Use `progress_bar` for a linear
bar.

## Example

```ruby
# indeterminate spinner
progress_ring()

# determinate (60%)
progress_ring(value: 0.6, stroke_width: 4)
```

## Common properties

- `value` — `nil` (spinner) or `0.0`–`1.0`
- `color`
- `bgcolor`
- `stroke_width`
- `stroke_cap`
- `stroke_align`
- `semantics_label`

## Usage

Show a spinner while loading, then swap in content:

```ruby
body = column(children: [progress_ring()])
page.add(body)

records = load_records          # slow work
page.update(body, children: records.map { |r| text(r.name) })
```

For a horizontal bar, `progress_bar(value: 0.6)`.
