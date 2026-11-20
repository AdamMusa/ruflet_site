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
read both from `event.control.props`. `on_change`, `on_change_start` and
`on_change_end` carry no data on any platform. `on_change` fires continuously
while a thumb moves; handle `on_change_end` to react once, when the user lets
go.

`event.control.start_value` and `event.control.end_value` return the same
values as `props["start_value"]` and `props["end_value"]`; with 0.0.23 they
raise NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS the client draws two stacked sliders instead of one slider
with two thumbs: the first runs from `min` to `end_value` and sets
`start_value`, the second runs from `start_value` to `max` and sets
`end_value`, and each splits its own span into `divisions` steps. They use
`active_color`; `label`, `round`, `inactive_color` and `overlay_color` apply on
Android, Windows and Linux only, and so does `mouse_cursor`. The events
and the values written back are the same on every platform. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.
