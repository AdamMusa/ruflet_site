# ResponsiveRow

A row whose children reflow across a responsive grid, like Bootstrap's grid
system. Each child occupies a number of columns out of `columns` (12 by
default), and that span can change per breakpoint as the window resizes. Mirrors
Flet's [`ResponsiveRow`](https://flet.dev/docs/controls/responsiverow).

`responsive_row` is a core control — no extension is required.

## Example

```ruby
responsive_row(
  spacing: 10,
  run_spacing: 10,
  columns: 12,
  children: [
    # Full width on phones, half on tablets, a third on desktops.
    container(col: { "xs" => 12, "sm" => 6, "md" => 4 }, content: text("A")),
    container(col: { "xs" => 12, "sm" => 6, "md" => 4 }, content: text("B")),
    container(col: { "xs" => 12, "sm" => 12, "md" => 4 }, content: text("C"))
  ]
)
```

A fixed split (sidebar + content):

```ruby
responsive_row(
  children: [
    container(col: 4, content: text("Sidebar")),
    container(col: 8, content: text("Content"))
  ]
)
```

The first positional argument is the `children` array, so
`responsive_row([...])` and `responsive_row(children: [...])` are equivalent.

## The `col` property (on children)

Children control their own span with the `col` property:

- An integer (`col: 6`) — the same span at every breakpoint.
- A hash (`col: { "sm" => 6, "md" => 4 }`) — a span per breakpoint. A breakpoint
  applies at its width and up until the next one is set, so omitted breakpoints
  inherit the nearest smaller one.

If a child has no `col`, it spans all `columns`.

## Breakpoints

`breakpoints` maps a name to the minimum viewport width (in pixels) at which it
applies. The defaults follow Bootstrap:

| Name  | Min width |
|-------|-----------|
| `xs`  | 0         |
| `sm`  | 576       |
| `md`  | 768       |
| `lg`  | 992       |
| `xl`  | 1200      |
| `xxl` | 1400      |

Override them by passing your own map:

```ruby
responsive_row(
  breakpoints: { "xs" => 0, "sm" => 600, "md" => 900 },
  children: responsive_children
)
```

## Properties

- `controls` — the child controls (also accepted as the first positional
  argument).
- `columns` — the total number of grid columns (default `12`).
- `spacing` — horizontal gap between children in the same run (default `10`).
- `run_spacing` — vertical gap between wrapped runs (default `10`).
- `alignment` — horizontal alignment of children within a run (`"start"`,
  `"center"`, `"end"`, `"space_between"`, `"space_around"`, `"space_evenly"`).
- `vertical_alignment` — cross-axis alignment of children (`"start"`,
  `"center"`, `"end"`, `"stretch"`).
- `breakpoints` — the breakpoint → min-width map described above.
- `expand` — fill the available space in a `column`.
- `width` / `height` — fixed size when not expanding.
- `tooltip`, `visible`, `opacity`, `rtl`, `disabled`, `animate_*` — the usual
  layout properties.

## Events

- `on_size_change` — the control's size changed.
- `on_animation_end` — an `animate_*` transition finished.

## Reference

- Family: `shared`
- Widget type: `responsiverow`
- Helper: `responsive_row`
