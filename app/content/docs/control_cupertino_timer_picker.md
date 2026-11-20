# CupertinoTimerPicker

The iOS timer wheels, for picking a countdown duration. `cupertino_timer_picker`
builds the same `TimerPicker` control as
[`timer_picker`](/docs/control-timer-picker) and sends the iOS defaults:
`item_extent: 32`, `alignment: "center"`, `minute_interval: 1`,
`second_interval: 1` and `mode: "hour_minute_seconds"`, which clients read as
`"hms"`. On Android, Windows and Linux the client draws a row of
dropdowns instead. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
chosen = text(value: "Countdown: 1 h 30 min")
page.add(
  column(
    children: [
      cupertino_timer_picker(
        value: 5400,
        mode: "hm",
        minute_interval: 5,
        height: 200,
        on_change: ->(event) {
          seconds = event.control.props["value"].to_i
          page.update(chosen, value: "Countdown: #{seconds / 3600} h #{seconds % 3600 / 60} min")
        }
      ),
      chosen
    ]
  )
)
```

## Common properties

- `value` — the duration in whole seconds (default 0)
- `mode` — `"hms"` (default), `"hm"` or `"ms"`; the default `"hour_minute_seconds"` this helper sends reads as `"hms"`
- `minute_interval` / `second_interval` — steps between the offered minutes and seconds
- `item_extent` — height of each row of the wheels
- `alignment` / `bgcolor`
- `on_change` — the duration changed

## Usage

The wheels send `on_change` as the user turns them, after the client writes the
new duration to `value`. With an Integer `value`, as above, `event.data` and
`event.control.props["value"]` are seconds. Without one they are both the
duration in microseconds, and `.to_i` gives the number: for 1 min 30 s, the
Integer 90000000 with 0.0.23. In the next release both are the String
`"90000000"`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Use a `minute_interval` that divides 60 and a `value` that is a whole number of
those steps. Give the picker a `height`: the wheels fill the height they are
given.

`event.control.value` returns the same value as `event.control.props["value"]`;
with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`item_extent`, `alignment` and `bgcolor` apply on iOS and macOS only.
