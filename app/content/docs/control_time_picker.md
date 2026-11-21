# TimePicker

A dialog for picking a time of day. Open it with `page.show_dialog(picker)`.
On Android, Windows and Linux the client shows the Material clock dialog;
on iOS and macOS a time wheel slides up from the bottom of the screen with
Cancel and Done. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
label = text(value: "No start time")
picker = time_picker(
  value: "09:30",
  help_text: "Pick a start time",
  on_change: ->(event) { page.update(label, value: "Starts at #{event.control.props["value"]}") }
)

page.add(
  column(
    children: [
      filled_button(content: text("Set time"), on_click: ->(_e) { page.show_dialog(picker) }),
      label
    ]
  )
)
```

## Common properties

- `value` — the selected time, set as `"HH:MM"`
- `hour_format` — `"h12"`, `"h24"` or `"system"` (default)
- `cancel_text` / `confirm_text` — the button labels
- `modal` — when true, tapping outside does not close the picker
- `help_text` — the dialog title, Android, Windows and Linux only
- `entry_mode` — `"dial"` or `"input"`, Android, Windows and Linux only
- `hour_label_text` / `minute_label_text` / `orientation` — Android, Windows and Linux only

## Usage

Read the choice in the handler with `event.control.props["value"]`. The picker
auto-confirms on the client and fires `on_change`; reopen it with
`page.show_dialog`. The client writes the picked time as hours and minutes
without leading zeros, for example `"9:5"` for 09:05 and `"14:30"`; `event.data`
holds the same string.

`on_dismiss` fires whenever the picker closes, after `on_change` when the user
picked a time. `event.data` is `true` when the user closed it without picking,
and `nil` when they picked one (the client sends `false`). On Android, Windows and Linux, `on_entry_mode_change` fires when the user switches between
the dial and text input; `event.data[:entry_mode]` (a Symbol key) is the new
mode.

`event.control.value` and `event.control.entry_mode` return the same values as
`props["value"]` and `props["entry_mode"]`; with 0.0.23 they raise
NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

`hour_format` follows the device setting by default on Android, Windows
and Linux. On iOS and macOS the wheel shows 24 hours only for `"h24"`, and AM
and PM otherwise. `help_text`, `entry_mode`, `hour_label_text`,
`minute_label_text`, `error_invalid_text`, `orientation`,
`switch_to_input_icon`, `switch_to_timer_icon`, `barrier_color`, `locale` and
`on_entry_mode_change` apply on Android, Windows and Linux only.
