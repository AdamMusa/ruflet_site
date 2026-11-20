# CupertinoSwitch

`cupertino_switch` builds the same `Switch` control as
[`switch`](/docs/control-switch). The client draws an iOS-style switch on iOS
and macOS and a Material switch elsewhere. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

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
- `on_label_color` / `off_label_color` — the on and off marks inside the track (iOS and macOS only)
- `on_change`

## Usage

Read the new state from `event.control.props["value"]`. The client updates
`value` before it sends `on_change`, on every platform. Do not rely on
`event.data`: the 0.0.23 iOS client sends the event without data, and other
clients send the new value, which Ruby receives as `nil` when it is `false`.

`event.control.value` returns the same value as `event.control.props["value"]`;
with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

iOS draws the on and off marks only when the user turns on On/Off Labels in
the accessibility settings; `on_label_color` and `off_label_color` color them,
and other platforms ignore both. On Android, Windows and Linux the client
draws a Material switch. To set its Material-only properties, such as
`track_color`, build it with [`switch`](/docs/control-switch), which sends the
same control.
