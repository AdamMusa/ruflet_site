# Stack

Layer controls on top of each other.

## Example

```ruby
stack(
  children: [
    container(width: 220, height: 140, bgcolor: "#1f2937"),
    container(width: 120, height: 48, bgcolor: "#0ea5e9")
  ]
)
```

## Common properties

- `children` — later children draw on top of earlier ones; the first positional argument sets them
- `expand`
- `width`
- `height`
- `alignment` — where children without a position sit, as `{ x:, y: }` from -1 to 1 (default the top left)
- `fit` — how those children are sized: `"loose"` (default), `"expand"` or `"passThrough"`
- `clip_behavior` — `"hardEdge"` (default) clips children that reach outside the stack; `"none"` lets them show

## Usage

Use `stack` for overlays, badges, or layered presentation:

```ruby
stack(
  children: [
    image("https://picsum.photos/320/180", width: 320, height: 180),
    container(
      padding: 8,
      bgcolor: "#111827cc",
      content: text(value: "Preview")
    )
  ]
)
```

## Positioning children

`left`, `top`, `right` and `bottom` on a child place it at that distance from
the stack's edges, in logical pixels. Setting both `left` and `right` (or `top`
and `bottom`) stretches the child between them. Only a child of a `stack` can
be positioned; anywhere else those keywords show an error. `animate_position`
animates a change of position.

```ruby
dot = container(width: 24, height: 24, border_radius: 12, bgcolor: "#dc2626", left: 0, top: 0, animate_position: 400)

page.add(
  column(
    children: [
      stack(
        width: 240,
        height: 120,
        children: [
          container(width: 240, height: 120, bgcolor: "#f1f5f9", border_radius: 12),
          container(left: 12, right: 12, bottom: 12, padding: 8, bgcolor: "#ffffff", content: text("Pinned to the bottom")),
          dot
        ]
      ),
      text_button(content: text("Move the dot"), on_click: ->(_event) { page.update(dot, left: 200, top: 8) })
    ]
  )
)
```

## Notes

- Child order matters because later controls render on top
