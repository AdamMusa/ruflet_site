# DateRangePicker

A modal calendar for choosing a start and an end date, such as a hotel stay.
Like [`date_picker`](/docs/control-date-picker), it is a dialog: open it with
`page.show_dialog`.

## Example

```ruby
stay = text(value: "No dates chosen")
picker = date_range_picker(
  start_value: "2026-07-01",
  end_value: "2026-07-07",
  first_date: "2026-01-01",
  last_date: "2026-12-31",
  help_text: "Select your stay",
  on_change: ->(event) {
    check_in = event.control.props["start_value"].to_s[0, 10]
    check_out = event.control.props["end_value"].to_s[0, 10]
    page.update(stay, value: "#{check_in} to #{check_out}")
  }
)
page.add(
  column(
    children: [
      filled_button("Choose dates", on_click: ->(_event) { page.show_dialog(picker) }),
      stay
    ]
  )
)
```

## Common properties

- `start_value` / `end_value` — the selected range, ISO dates such as `"2026-07-01"`
- `first_date` / `last_date` — the selectable span
- `current_date` — the date shown as today
- `entry_mode` — `"calendar"` or `"input"`
- `help_text` / `cancel_text` / `confirm_text` / `save_text`
- `field_start_label_text` / `field_end_label_text` — labels in input mode
- `on_change` — the user confirmed a range
- `on_dismiss` — the picker closed; `event.data` is `true` when it closed without a new range

## Usage

The client writes the chosen range to `start_value` and `end_value` before it
sends `on_change`, so read them from `event.control.props`, as above.
