# Container

A single-child layout surface for spacing, sizing, alignment, and decoration.

## Example

```ruby
container(
  padding: 16,
  margin: 12,
  border_radius: 12,
  bgcolor: "#111827",
  content: text(value: "Card content")
)
```

## Common properties

- `content`
- `padding`
- `margin`
- `width`
- `height`
- `expand`
- `bgcolor`
- `border`
- `border_radius`
- `alignment`
- `on_click`

## Usage

Use `container` when a control needs its own box, spacing, or click surface:

```ruby
container(
  expand: true,
  alignment: "center",
  content: text(value: "Centered")
)
```

## Notes

- `container` takes one nested child through `content:`
- `alignment: "center"` is normalized by Ruflet for convenience
