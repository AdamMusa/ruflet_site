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
    check_in = event.control.props["start_value"]
    check_out = event.control.props["end_value"]
    page.update(stay, value: "From #{check_in} to #{check_out}")
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

- `start_value` / `end_value` — the selected range: set them as dates such as `"2026-07-01"`; after a pick they hold UTC timestamps (see below)
- `first_date` / `last_date` — the selectable span
- `current_date` — the date shown as today
- `entry_mode` — `"calendar"` or `"input"`
- `help_text` / `cancel_text` / `confirm_text` / `save_text`
- `field_start_label_text` / `field_end_label_text` — labels in input mode
- `on_change` — the user confirmed a range
- `on_dismiss` — the picker closed; `event.data` is `true` when it closed without a new range

## Usage

The client writes the chosen range to `start_value` and `end_value` before it
sends `on_change`, so read them from `event.control.props`, as above. It writes
each day as the UTC time of its local midnight: in UTC+2, a 3 to 9 July stay
arrives as `"2026-07-02T22:00:00.000+00:00"` and
`"2026-07-08T22:00:00.000+00:00"`. The first ten characters are therefore the
day before for users east of UTC. The client does not send its UTC offset, so
keep the full timestamps, or ask the user for their time zone before you turn
them into calendar dates.
