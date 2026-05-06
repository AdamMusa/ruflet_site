# Tabs

Switch between related views inside one screen.

## Example

```ruby
tabs(
  selected_index: 0,
  tabs: [
    tab(text: "Home", content: text(value: "Home content")),
    tab(text: "Profile", content: text(value: "Profile content"))
  ]
)
```

## Common properties

- `selected_index`
- `tabs`
- `animation_duration`
- `expand`
- `on_change`

## Usage

```ruby
tabs(
  expand: true,
  tabs: [
    tab(text: "All", content: text(value: "All items")),
    tab(text: "Open", content: text(value: "Open items"))
  ]
)
```

## Notes

- Each `tab(...)` usually defines both a label and `content:`
