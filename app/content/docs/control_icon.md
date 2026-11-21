# Icon

Display a standalone icon.

## Example

```ruby
icon("home")
```

## Common properties

- `icon`
- `size` — in logical pixels (default 24)
- `color`
- `semantics_label` — what screen readers say for the icon
- `fill`, `weight`, `grade` and `optical_size` — axes of variable icon fonts such as Material Symbols; fonts without them ignore these

## Usage

```ruby
row(
  spacing: 8,
  children: [
    icon(Ruflet::MaterialIcons::ADD),
    text(value: "Create")
  ]
)
```

## Notes

- Ruflet accepts icon name strings like `"add"`
- Ruflet also accepts `Ruflet::MaterialIcons::*`
