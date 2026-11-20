# Badge

A small count or status marker drawn on the corner of another control — most
often an icon or button. In Ruflet, `badge` is passed as the `badge:` property
of the control it decorates.

## Example

```ruby
icon_button(
  "notifications",
  badge: badge("3"),
  on_click: ->(_e) { open_inbox }
)
```

## Common properties

- `label` — the label control or value inside the badge; the first positional
  argument maps to this property
- `label_visible` — show / hide the badge
- `bgcolor`
- `text_color`
- `alignment`
- `offset`
- `small_size` / `large_size`

## Usage

Most controls accept a `badge:` property. Pass a plain string for a dot-style
badge, or a `badge(...)` for a counted/styled one. Toggle `label_visible` to
show or hide it without rebuilding the parent.
