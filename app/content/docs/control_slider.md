# Slider

A material slider for selecting a value from a continuous or discrete range.

## Example

```ruby
slider(
  value: 40,
  min: 0,
  max: 100,
  divisions: 10,
  label: "{value}%",
  on_change: ->(event) { page.update(preview, opacity: event.control.value / 100.0) }
)
```

## Common properties

- `value`
- `min` / `max`
- `divisions` — snap to discrete steps
- `label` — tooltip shown while dragging (`"{value}"` interpolates)
- `active_color` / `inactive_color`
- `thumb_color`
- `round` — decimal places for the displayed value

## Range slider

For two-handle selection, use `range_slider` with `start_value` / `end_value`:

```ruby
range_slider(start_value: 20, end_value: 80, min: 0, max: 100, divisions: 10)
```

## Usage

`on_change` fires continuously while dragging; use `on_change_end` to react only
when the user releases.
