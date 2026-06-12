# DatePicker

A modal calendar for selecting a date. It is shown as a dialog, so it is opened
through the page (`show_dialog`) rather than placed inline.

## Example

```ruby
picker = date_picker(
  value: "2026-01-15",
  first_date: "2026-01-01",
  last_date: "2026-12-31",
  on_change: ->(event) { page.update(label, value: event.control.value) }
)

filled_button(content: text("Pick a date"), on_click: ->(_e) { page.show_dialog(picker) })
```

## Common properties

- `value` — the selected date (ISO `YYYY-MM-DD`)
- `first_date` / `last_date` — the selectable range
- `current_date`
- `date_picker_mode` — `"day"`, `"year"`
- `entry_mode` — `"calendar"`, `"input"`
- `help_text` / `cancel_text` / `confirm_text`
- `field_label_text` / `field_hint_text`

## Related

- [`time_picker`](/docs/control-time-picker) for a time of day.
- `date_range_picker` for a start/end range — read `start_value` and
  `end_value`.

## Usage

The picker confirms itself on the client and reports the new value through
`on_change`. Read it with `control.value`. Reopen it with `page.show_dialog`
again — it reopens cleanly after a selection.
