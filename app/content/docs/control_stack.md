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

- `children`
- `expand`
- `width`
- `height`

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

## Notes

- Child order matters because later controls render on top
