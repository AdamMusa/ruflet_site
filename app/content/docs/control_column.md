# Column

A vertical layout control for stacking children.

## Example

```ruby
column(
  spacing: 12,
  children: [
    text(value: "Title", style: { size: 24 }),
    text(value: "Subtitle"),
    text_field(label: "Name")
  ]
)
```

## Common properties

- `children`
- `spacing`
- `expand`
- `horizontal_alignment`
- `scroll`

## Usage

```ruby
page.add(
  column(
    spacing: 10,
    children: [
      text(value: "Profile"),
      text_field(label: "Display name")
    ]
  )
)
```

## Notes

- `children` should be an array of controls
- `column` is one of the most common layout primitives in Ruflet apps
