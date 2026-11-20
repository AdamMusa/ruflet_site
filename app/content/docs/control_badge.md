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

- `label` — the text or control inside the badge; the first positional
  argument maps to this property. Give a String: a number is not shown as a
  label, so write `badge(count.to_s)`
- `label_visible` — show / hide the badge
- `bgcolor` — red by default
- `text_color` / `text_style`
- `alignment` — the corner, as `{ x:, y: }` from -1 to 1 (default the top right)
- `offset` — move the badge from its corner, as `{ x:, y: }` in logical pixels
- `small_size` / `large_size` — the dot's diameter and a labelled badge's height

## Usage

Most controls accept a `badge:` property. Pass a plain String or number, such
as `badge: "3"`, for a badge with that label, or a `badge(...)` for a styled one.
Toggle `label_visible` to show or hide it without rebuilding the parent.

A `badge()` with no label draws a small dot on Android, web, Windows and Linux.
iOS and macOS need a label: there a badge without one shows the control's
internal data as text, so give every badge a label when your app runs on Apple
platforms.
