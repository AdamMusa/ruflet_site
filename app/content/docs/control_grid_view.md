# GridView

Display repeated content in a tiled layout.

## Example

```ruby
grid_view(
  runs_count: 2,
  spacing: 8,
  run_spacing: 8,
  controls: [
    text(value: "A"),
    text(value: "B"),
    text(value: "C"),
    text(value: "D")
  ]
)
```

## Common properties

- `runs_count`
- `controls`
- `children`
- `spacing`
- `run_spacing`
- `expand`

## Usage

```ruby
grid_view(
  runs_count: 3,
  spacing: 12,
  controls: items.map { |item| text(value: item[:name]) }
)
```

## Notes

- Ruflet accepts both `controls:` and `children:` in common examples
