# Icon

Display a standalone icon.

## Example

```ruby
icon(icon: "home")
```

## Common properties

- `icon`
- `size`
- `color`

## Usage

```ruby
row(
  spacing: 8,
  children: [
    icon(icon: Ruflet::MaterialIcons::ADD),
    text(value: "Create")
  ]
)
```

## Notes

- Ruflet accepts icon name strings like `"add"`
- Ruflet also accepts `Ruflet::MaterialIcons::*`
