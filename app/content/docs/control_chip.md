# Chip

A compact element for an attribute, filter, or action. Chips are commonly shown
in a `row` and can be selectable or deletable.

## Example

```ruby
row(
  spacing: 8,
  controls: %w[All Open Closed].map do |label|
    chip(
      label: text(label),
      selected: label == "Open",
      on_click: ->(_e) { set_filter(label) }
    )
  end
)
```

## Common properties

- `label` — the chip's content control
- `selected` / `selected_color`
- `leading` — a leading control (often an avatar or icon)
- `show_checkmark`
- `delete_icon` / `on_delete` — make the chip deletable
- `bgcolor`
- `shape`
- `border_side`

## Usage

Read or toggle `selected` to drive filter UIs. Add a `delete_icon` and handle
`on_delete` for removable tags.
