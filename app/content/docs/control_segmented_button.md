# SegmentedButton

A row of connected buttons for picking one option, or several, from a small
set. Each option is a [`segment`](/docs/control-segment) with a `value`.

## Example

```ruby
view_label = text(value: "Showing: week")
page.add(
  segmented_button(
    [
      segment("day", label: text("Day"), icon: icon("calendar_view_day")),
      segment("week", label: text("Week"), icon: icon("calendar_view_week")),
      segment("month", label: text("Month"), icon: icon("calendar_month"))
    ],
    selected: ["week"],
    on_change: ->(event) { page.update(view_label, value: "Showing: #{Array(event.data).join(', ')}") }
  )
)
page.add(view_label)
```

## Common properties

- `segments` — the `segment(...)` options; the first positional argument sets them
- `selected` — the list of selected segment values
- `allow_multiple_selection` — let several segments be selected
- `allow_empty_selection` — let the user clear the selection
- `show_selected_icon` / `selected_icon` — the check mark on selected segments
- `direction` — `"horizontal"` (default) or `"vertical"`
- `style` — colors, padding and shape
- `on_change` — `event.data` is the list of selected values

## Usage

By default exactly one segment must be selected, so start with one value in
`selected`. For a multi-select filter, allow both multiple and empty
selections:

```ruby
segmented_button(
  [segment("s", label: "S"), segment("m", label: "M"), segment("l", label: "L")],
  selected: ["s", "m"],
  allow_multiple_selection: true,
  allow_empty_selection: true
)
```
