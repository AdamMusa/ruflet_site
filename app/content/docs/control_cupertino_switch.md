# CupertinoSwitch

`cupertino_switch` builds the same `Switch` control as
[`switch`](/docs/control-switch). The client draws an iOS-style switch on iOS
and macOS and a Material switch elsewhere.

## Example

```ruby
status = text(value: "Wi-Fi is on")
page.add(
  column(
    children: [
      cupertino_switch(
        label: "Wi-Fi",
        value: true,
        active_track_color: "#4ade80",
        on_change: ->(event) {
          on = event.control.props["value"]
          page.update(status, value: on ? "Wi-Fi is on" : "Wi-Fi is off")
        }
      ),
      status
    ]
  )
)
```

## Common properties

- `value` — `true` or `false`
- `label` / `label_position` (`"right"` or `"left"`)
- `active_track_color` / `inactive_track_color` / `inactive_thumb_color`
- `thumb_color` / `thumb_icon`
- `track_outline_color` / `track_outline_width`
- `on_label_color` / `off_label_color` — the on and off marks inside the track
- `on_change`

## Usage

Read the new state from `event.control.props["value"]`. The client updates
`value` before it sends `on_change`, and on iOS the event itself carries no
data.
