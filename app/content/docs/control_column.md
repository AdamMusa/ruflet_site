# Column

A vertical layout control for stacking children.

## Example

```ruby
column(
  spacing: 12,
  children: [
    text(value: "Title", style: { size: 24 }),
    text(value: "Subtitle"),
    text_field(label: "Name")
  ]
)
```

## Common properties

- `children` — the controls, top to bottom; the first positional argument sets them
- `spacing` — space between children, in logical pixels (default 10)
- `alignment` — vertical placement: `"start"` (default), `"center"`, `"end"`, `"spaceBetween"`, `"spaceAround"` or `"spaceEvenly"`
- `horizontal_alignment` — `"start"` (default), `"center"`, `"end"` or `"stretch"`
- `tight` — take only the height the children need instead of all that is offered
- `expand` — fill the free space of the parent row, column or page; children with `expand:` share the column's own free height
- `wrap` — flow the children into further columns when they do not fit, with `run_spacing` and `run_alignment` between the columns
- `intrinsic_width` — make the column as wide as its widest child
- `scroll` — scroll when the children overflow: `"auto"`, `"adaptive"`, `"always"` or `"hidden"`
- `auto_scroll` — scroll to the end whenever the children change, as in a log
- `on_scroll` — with `scroll` set; `event.data` has `"event_type"`, `"pixels"`, `"max_scroll_extent"` and more, as listed under Events below

## Usage

```ruby
page.add(
  column(
    spacing: 10,
    children: [
      text(value: "Profile"),
      text_field(label: "Display name")
    ]
  )
)
```

Give children `expand:` to split the column's height between them. The column
itself needs a bounded height for that, such as `expand: true` on the column in
the page:

```ruby
page.add(
  column(
    expand: true,
    children: [
      container(expand: 2, bgcolor: "#dbeafe", content: text("Two thirds")),
      container(expand: 1, bgcolor: "#dcfce7", content: text("One third"))
    ]
  )
)
```

## Refreshing and loading more

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 these keywords raise ArgumentError (unknown keyword).

Pull to refresh, `on_end_reached`, `keyboard_dismiss_behavior`,
`animate_changes` with `item_animation`, and `scroll_to` are covered in
[Controls and Layout](/docs/controls-and-layout#scrolling).

- `on_end_reached` — `event.data` has `"pixels"`, `"max_scroll_extent"` and `"viewport_dimension"`.
- `refresh_bgcolor` and `refresh_displacement` apply on Android, web, Windows and Linux only; `refresh_trigger_distance` on iOS and macOS only.

## Notes

- `children` should be an array of controls
- `column` is one of the most common layout primitives in Ruflet apps
- For long lists, use [`list_view`](/docs/control-list-view), which builds only the items on screen
