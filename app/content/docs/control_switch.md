# Switch

An on/off toggle with an optional label. The client draws an iOS-style switch
on iOS and macOS and a Material switch on Android, Windows and Linux;
[`cupertino_switch`](/docs/control-cupertino-switch) builds the same control. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
status = text(value: "Email notifications are on")
page.add(
  column(
    children: [
      switch(
        label: "Email notifications",
        value: true,
        on_change: ->(event) {
          on = event.control.props["value"]
          page.update(status, value: "Email notifications are #{on ? 'on' : 'off'}")
        }
      ),
      status
    ]
  )
)
```

## Common properties

- `value` — `true` / `false`
- `label`
- `label_position` — `"left"` or `"right"`
- `active_color` / `active_track_color`
- `inactive_thumb_color` / `inactive_track_color`
- `thumb_color` / `thumb_icon`
- `track_color`

## Usage

In `on_change`, read the new state from `event.control.props["value"]`; the
client writes it to the control before the event fires. Prefer it to
`event.data`, which the iOS switch can leave empty. To use the state later,
keep it in Ruby state or read `toggle.props["value"]`:

```ruby
dark_mode = false
toggle = switch(
  label: "Dark mode",
  value: dark_mode,
  on_change: ->(event) { dark_mode = event.control.props["value"] }
)
page.add(toggle)

# later, for example in another handler:
dark_mode             # => true after the user turns it on
toggle.props["value"] # => true
```

`event.control.value` and `toggle.value` return the same value as
`props["value"]`; with 0.0.23 they raise NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

On iOS and macOS the switch has no ink and no separate thumb color for the on
state: `active_color`, `track_color`, `hover_color`, `overlay_color`,
`splash_radius` and `padding` apply on Android, Windows and Linux only.
There, use `thumb_color`, `active_track_color` and `inactive_track_color`.
`on_label_color` and `off_label_color` color the on and off marks that iOS
draws in the track when the user turns on On/Off Labels in the accessibility
settings; other platforms ignore them.
