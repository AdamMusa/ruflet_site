# TimerPicker

Picks a duration in hours, minutes and seconds, for a countdown or a timer. On
iOS and macOS the client draws the iOS timer wheels; on Android, Windows
and Linux a row of dropdowns, one per unit.
[`cupertino_timer_picker`](/docs/control-cupertino-timer-picker) builds the
same control with the iOS defaults. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
remaining = text(value: "Timer: 5 min 0 s")
page.add(
  column(
    children: [
      timer_picker(
        value: 300,
        mode: "ms",
        second_interval: 5,
        height: 180,
        on_change: ->(event) {
          seconds = event.control.props["value"].to_i
          page.update(remaining, value: "Timer: #{seconds / 60} min #{seconds % 60} s")
        }
      ),
      remaining
    ]
  )
)
```

## Common properties

- `value` — the duration in whole seconds (default 0)
- `mode` — `"hms"` (hours, minutes and seconds; default), `"hm"` or `"ms"`
- `minute_interval` / `second_interval` — steps between the offered minutes and seconds
- `on_change` — the duration changed

## Usage

Set `value` as an Integer number of seconds, as above. The client writes the
new duration to `value` before it sends `on_change`, and keeps the type: for an
Integer `value` both `event.data` and `event.control.props["value"]` are
seconds. Without an Integer `value` (also when you leave it out) the client
sends the duration in microseconds: for 1 min 30 s, `event.data` and
`event.control.props["value"]` are both the Integer 90000000.

`event.control.value` returns the same value as `event.control.props["value"]`;
with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Use intervals that divide 60, and a `value` that is a whole number of those
steps.

## Platform differences

`item_extent`, `alignment` and `bgcolor` style the iOS wheels and apply on iOS
and macOS only. On iOS and macOS the wheels fill the height they are given,
so give the picker a `height`.
