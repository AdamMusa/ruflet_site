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

The client writes the new selection to `selected` before it sends
`on_change`, and `event.data` is the same list of values. Read it later from
the button's `props["selected"]`. `event.control.selected` returns the same list
as `props["selected"]`; with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS each segment is a Cupertino button, filled when selected and
tinted otherwise. On a selected segment, `selected_icon` takes the place of the
segment's icon. When it is not set, Android, web, Windows and Linux show a
check mark there and iOS and macOS show no icon. Set
`show_selected_icon: false` to keep each segment's own icon. `style` and the segments' `tooltip` apply on Android, web,
Windows and Linux only. `border_color`, `selected_color`, `unselected_color`,
`click_color`, `disabled_color` and `disabled_text_color` apply on iOS and
macOS only.

`sliding: true` draws the iOS sliding segmented control on iOS and macOS, as
[`cupertino_sliding_segmented_button`](/docs/control-cupertino-sliding-segmented-button)
does, and only then do `bgcolor`, `thumb_color` and `proportional_width` take
effect. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

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
