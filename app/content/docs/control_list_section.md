# ListSection

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A group of rows with an optional header and footer, like a section of the iOS
Settings app. Material clients draw a card of rows with inset dividers.

## Example

```ruby
page.add(
  list_section(
    [
      list_tile(title: text("Wi-Fi"), trailing: text("Home")),
      list_tile(title: text("Bluetooth"), trailing: text("On")),
      list_tile(title: text("Airplane mode"), trailing: switch(value: false))
    ],
    header: text("Connections"),
    footer: text("Changes apply to this device only.")
  )
)
```

Give the rows as the first argument, as `children:`, or in a block.

## Properties

- `header` and `footer` — controls above and below the rows.
- `variant` — `"insetGrouped"` (default): rounded rows inset from the screen edges; `"base"`: edge to edge.
- `has_leading` — the rows have leading icons, so dividers start after them (default `true`).
- `bgcolor`, `rows_bgcolor` and `separator_color` — section, row and divider colors.
- `divider_margin`, `additional_divider_margin` and `top_margin` — divider insets and space above the section.
- `border_radius`, `clip_behavior`, `margin` and the common layout properties.

Use [`form_row`](/docs/control-form-row) rows for labeled settings fields.
