# DatePicker

A dialog for picking a date. Open it with `page.show_dialog(picker)`. On
Android, Windows and Linux the client shows the Material calendar dialog;
on iOS and macOS a date wheel slides up from the bottom of the screen with
Cancel and Done. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
label = text(value: "No date yet")
picker = date_picker(
  value: "2026-01-15",
  first_date: "2026-01-01",
  last_date: "2026-12-31",
  help_text: "Pick a delivery date",
  on_change: ->(event) { page.update(label, value: "Delivery on #{event.control.props["value"].to_s[0, 10]}") }
)

page.add(
  column(
    children: [
      filled_button(content: text("Pick a date"), on_click: ->(_e) { page.show_dialog(picker) }),
      label
    ]
  )
)
```

## Common properties

- `value` — the selected date, set as `"YYYY-MM-DD"`
- `first_date` / `last_date` — the selectable range
- `current_date` — the date shown as today
- `help_text` — the title; `cancel_text` / `confirm_text` — the button labels
- `modal` — when true, tapping outside does not close the picker
- `date_picker_mode` — the view it starts in (see below)
- `entry_mode` — `"calendar"` or `"input"`, Android, Windows and Linux only
- `field_label_text` / `field_hint_text` — the input-mode field, Android, Windows and Linux only

## Related

- [`time_picker`](/docs/control-time-picker) for a time of day.
- [`date_range_picker`](/docs/control-date-range-picker) for a start/end range — read `start_value` and
  `end_value`.
- [`cupertino_date_picker`](/docs/control-cupertino-date-picker) for an iOS-style wheel.

## Usage

The picker confirms itself on the client and reports the new value through
`on_change`. Read it in the handler with `event.control.props["value"]`.
Reopen it with `page.show_dialog` again — it reopens cleanly after a selection.

The client writes the picked day as the UTC time of its local midnight, for
example `"2026-01-14T23:00:00.000+00:00"` for 15 January in UTC+1, so for users
east of UTC the first ten characters are the day before. Keep the full
timestamp when that matters, as the
[`date_range_picker`](/docs/control-date-range-picker) page explains.

`on_dismiss` fires whenever the picker closes, after `on_change` when the user
picked a date. `event.data` is `true` when the user closed it without picking,
and `nil` when they picked one (the client sends `false`). On Android, Windows and Linux, `on_entry_mode_change` fires when the user switches between
the calendar and text input; `event.data[:entry_mode]` (a Symbol key) is the new
mode, which the client also writes to `entry_mode`.

`event.control.value` and `event.control.entry_mode` return the same values as
`props["value"]` and `props["entry_mode"]`; with 0.0.23 they raise
NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

`date_picker_mode` means a different thing on each design. On Android, Windows and Linux it is the calendar view the dialog starts in: `"day"`
(default) or `"year"`. On iOS and macOS it picks the wheels: `"date"`
(default), `"time"`, `"dateAndTime"` or `"monthYear"`.

The Material dialog's input mode and styling apply on Android, Windows
and Linux only: `entry_mode`, `field_label_text`, `field_hint_text`,
`error_format_text`, `error_invalid_text`, `keyboard_type`,
`switch_to_calendar_icon`, `switch_to_input_icon`, `barrier_color` and
`inset_padding`, as well as `on_entry_mode_change`. The wheel
properties apply on iOS and macOS only: `date_order`, `minimum_year`,
`maximum_year`, `show_day_of_week`, `use_24h_format`, `minute_interval`,
`item_extent` and `bgcolor`.
