# GridView

Display repeated content in a tiled layout.

## Example

```ruby
grid_view(
  runs_count: 2,
  spacing: 8,
  run_spacing: 8,
  children: [
    text(value: "A"),
    text(value: "B"),
    text(value: "C"),
    text(value: "D")
  ]
)
```

## Common properties

- `runs_count`
- `children`
- `spacing`
- `run_spacing`
- `expand`

## Usage

```ruby
grid_view(
  runs_count: 3,
  spacing: 12,
  children: items.map { |item| text(value: item[:name]) }
)
```

## Notes

- Use `children:` for the tiles, consistent with `column`, `row`, and
  `list_view`. (`controls:` is still accepted for backward compatibility.)
