# Text

Display labels, headings, counters, and inline status values.

## Example

```ruby
text(value: "Dashboard", style: { size: 28, weight: "w700" })
```

## Common properties

- positional value: `text("Hello")`
- keyword value: `text(value: "Hello")`
- `style`
- `selectable`

## Usage

```ruby
title = text(value: "Ruflet", style: { size: 28, weight: "w700" })
subtitle = text("Ruby UI for every screen")
```

## Notes

Common `style` keys used in Ruflet examples:

- `size`
- `weight`
- `color`

`text` also takes the most common style keys directly: `size`, `weight`
(`"normal"`, `"bold"` or `"w100"` to `"w900"`), `italic`, `color`, `bgcolor`,
`font_family` and `text_align`. `theme_style` picks one of the theme's text
styles, such as `"headline_small"`.

## Long text

`max_lines` limits the number of lines, and `overflow` says how cut-off text
ends: `"ellipsis"` adds an ellipsis, `"fade"` fades it out, `"clip"` cuts it.
`no_wrap: true` keeps the text on one line.

```ruby
text(
  "Ruflet renders Flutter widgets from Ruby, so one codebase runs on phones, desktops and the web.",
  max_lines: 1,
  overflow: "ellipsis"
)
```

`text` also accepts `ellipsis:`, `x`, `y`, `max_width` and `alignment`, but
only text drawn as a shape inside a [`canvas`](/docs/control-canvas) uses them.
On the page, use `overflow: "ellipsis"` and `text_align`.

## Spans

`spans` adds inline pieces with their own style, link or tap handler, built
with [`text_span`](/docs/control-text-span):

```ruby
text(
  "Read the ",
  spans: [
    text_span("guide", url: "https://ruflet.dev/docs", style: { color: "#2563eb", decoration: Ruflet::TextDecoration::UNDERLINE }),
    text_span(" first.")
  ]
)
```

## Selection and taps

- `selectable: true` lets the user select and copy the text. `selection_cursor_color` colors the cursor and handles; `show_selection_cursor`, `selection_cursor_width` and `selection_cursor_height` apply on Android, web, Windows and Linux only.
- `on_selection_change` — `event.data` has the keys `:selected_text`, `:cause` and `:selection`, a hash with `:base_offset` and `:extent_offset`. On iOS and macOS `:selected_text` is the selected part; on Android, web, Windows and Linux it is the whole text, so cut it with the offsets.
- `on_tap` — on Android, web, Windows and Linux it fires only for `selectable: true` text; iOS and macOS send it for any text. To make plain text tappable everywhere, wrap it in a [`gesture_detector`](/docs/control-gesture-detector) or a `container` with `on_click`.

```ruby
quote = "Simplicity is prerequisite for reliability."
picked = text(value: "")

page.add(
  column(
    children: [
      text(
        quote,
        selectable: true,
        on_selection_change: ->(event) {
          range = event.data[:selection]
          from, to = [range[:base_offset], range[:extent_offset]].minmax
          page.update(picked, value: "Selected: #{quote[from...to]}")
        }
      ),
      picked
    ]
  )
)
```
