# RangeSlider

A slider with two thumbs for choosing a range, such as a price band. Use
[`slider`](/docs/control-slider) for a single value.

## Example

```ruby
price = text(value: "$20 to $80")
page.add(
  range_slider(
    start_value: 20,
    end_value: 80,
    min: 0,
    max: 100,
    divisions: 20,
    label: "${value}",
    on_change: ->(event) {
      low = event.control.props["start_value"].to_i
      high = event.control.props["end_value"].to_i
      page.update(price, value: "$#{low} to $#{high}")
    }
  )
)
page.add(price)
```

## Common properties

- `start_value` / `end_value` — the two ends of the range
- `min` / `max`
- `divisions` — snap the thumbs to discrete steps
- `label` — the value labels shown while dragging; `{value}` is replaced by each thumb's value
- `round` — decimal places used in `label`
- `active_color` / `inactive_color` / `overlay_color`

## Usage

The client updates `start_value` and `end_value` before it sends the event, so
read both from `event.control.props`. `on_change` fires continuously while a
thumb moves; handle `on_change_end` to react once, when the user lets go.
