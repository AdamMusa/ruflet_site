# Row

A horizontal layout control for arranging children in a line.

## Example

```ruby
row(
  spacing: 8,
  alignment: Ruflet::MainAxisAlignment::CENTER,
  children: [
    icon(icon: "add"),
    text(value: "Create")
  ]
)
```

## Common properties

- `children`
- `spacing`
- `alignment`
- `vertical_alignment`
- `expand`

## Usage

```ruby
row(
  spacing: 10,
  children: [
    filled_button(content: text(value: "Save")),
    control(:outlined_button, content: text(value: "Cancel"))
  ]
)
```

## Notes

- `alignment` controls main-axis placement
- `row` is usually paired with `column` and `container`
