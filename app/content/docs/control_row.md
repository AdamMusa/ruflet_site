# Row

A horizontal layout control for arranging children in a line.

## Example

```ruby
row(
  spacing: 8,
  alignment: Ruflet::MainAxisAlignment::CENTER,
  children: [
    icon("add"),
    text(value: "Create")
  ]
)
```

## Common properties

- `children` — the controls, left to right; the first positional argument sets them
- `spacing` — space between children, in logical pixels (default 10)
- `alignment` — horizontal placement: `"start"` (default), `"center"`, `"end"`, `"spaceBetween"`, `"spaceAround"` or `"spaceEvenly"`
- `vertical_alignment` — `"start"`, `"center"` (default), `"end"`, `"stretch"` or `"baseline"`
- `tight` — take only the width the children need instead of all that is offered
- `expand` — fill the free space of the parent column, row or page; children with `expand:` share the row's own free width
- `wrap` — flow the children onto further lines when they do not fit, with `run_spacing` and `run_alignment` between the lines
- `intrinsic_height` — make the row as tall as its tallest child, so `vertical_alignment: "stretch"` gives every child that height
- `scroll` — scroll horizontally when the children overflow: `"auto"`, `"adaptive"`, `"always"` or `"hidden"`
- `on_scroll` — with `scroll` set; `event.data` has the keys `:event_type`, `:pixels`, `:max_scroll_extent` and more, as listed under Events below

## Usage

```ruby
row(
  spacing: 10,
  children: [
    filled_button(content: text(value: "Save")),
    outlined_button(content: text(value: "Cancel"))
  ]
)
```

Chips and tags that should flow onto new lines:

```ruby
row(
  wrap: true,
  spacing: 8,
  run_spacing: 8,
  children: %w[Ruby Flutter Rails Sinatra Hanami Roda].map { |tag| chip(label: text(tag)) }
)
```

## Notes

- `alignment` controls main-axis placement
- `row` is usually paired with `column` and `container`
- `on_end_reached`, `end_reached_threshold` and `keyboard_dismiss_behavior` work on a scrolling row too; see [Controls and Layout](/docs/controls-and-layout#scrolling). **Requires the next Ruflet release** (on `main`, not in 0.0.23).
