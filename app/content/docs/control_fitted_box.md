# FittedBox

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

Scales its `content` to fit the box it is given, for example a large number
that must fit a small tile without wrapping.

## Example

```ruby
page.add(
  container(
    width: 120,
    height: 48,
    content: fitted_box(
      text(value: "1,234,567", style: { size: 40, weight: "w700" }),
      fit: "scale_down"
    )
  )
)
```

The content is the first argument or `content:`. Size the box itself with its
parent, or with `width`, `height` or `expand`.

## Properties

- `content` — the control to scale.
- `fit` — `"contain"` (default), `"cover"`, `"fill"`, `"fit_width"`, `"fit_height"`, `"none"` or `"scale_down"`.
- `alignment` — where the scaled content sits inside the box.
- `clip_behavior` — clip content that overflows, for example with `"cover"`.
- `expand`, `width`, `height` and the common layout properties.
