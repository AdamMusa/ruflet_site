# CupertinoCheckbox

`cupertino_checkbox` builds the same `Checkbox` control as
[`checkbox`](/docs/control-checkbox), with iOS defaults: it sends
`value: false`, `tristate: false`, `label_position: "right"` and a 10-point
`spacing` between box and label. The client draws an iOS-style checkbox on iOS
and macOS and a Material one on Android, web, Windows and Linux.

## Example

```ruby
status = text(value: "Reminders off")
page.add(
  column(
    children: [
      cupertino_checkbox(
        label: "Remind me",
        active_color: "#34c759",
        on_change: ->(event) {
          on = event.control.props["value"]
          page.update(status, value: on ? "Reminders on" : "Reminders off")
        }
      ),
      status
    ]
  )
)
```

## Common properties

- `value` — `true` or `false` (default); `nil` is the mixed state of a `tristate` checkbox
- `label` / `label_position` (`"right"` or `"left"`); tapping the label toggles the box too
- `tristate` — allow the mixed state; a tap cycles unchecked, checked and mixed
- `active_color` / `check_color` / `fill_color` / `border_side` / `shape`
- `on_change`

## Usage

Read the new state in `on_change` from `event.control.props["value"]`: the
client writes it before it sends the event. `event.data` is `true` when the box
was checked and `nil`, not `false`, when it was cleared.

`event.control.value` returns the same value as `event.control.props["value"]`;
with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`cupertino_checkbox` accepts no `error`, `hover_color`, `overlay_color`,
`splash_radius` or `visual_density`: they style the Material checkbox only.
Build it with `checkbox` when you need them on Android, web, Windows and Linux.

On Android, web, Windows and Linux, the 0.0.23 client ignores `spacing`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
