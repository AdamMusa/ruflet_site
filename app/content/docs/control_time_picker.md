# TimePicker

A modal clock for selecting a time of day. Like the date picker, it is shown as
a dialog through the page.

## Example

```ruby
picker = time_picker(
  value: "09:30",
  help_text: "Pick a start time",
  on_change: ->(event) { page.update(label, value: event.control.value) }
)

filled_button(content: text("Set time"), on_click: ->(_e) { page.show_dialog(picker) })
```

## Common properties

- `value` — the selected time (`HH:MM`)
- `hour_format` — 12- or 24-hour display
- `entry_mode` — `"dial"`, `"input"`
- `help_text` / `cancel_text` / `confirm_text`
- `hour_label_text` / `minute_label_text`
- `orientation`

## Usage

Read the choice with `control.value`. The picker auto-confirms on the client and
fires `on_change`; reopen it with `page.show_dialog`.
