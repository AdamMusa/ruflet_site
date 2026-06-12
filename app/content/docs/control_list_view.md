# ListView

A scrollable list of controls, optimized for many items. Prefer it over a
scrolling `column` when the list is long.

## Example

```ruby
list_view(
  expand: true,
  spacing: 4,
  padding: 8,
  controls: messages.map { |m| list_tile(title: text(m.subject), subtitle: text(m.preview)) }
)
```

## Common properties

- `controls` — the list items
- `horizontal` — scroll horizontally instead of vertically
- `spacing`
- `padding`
- `item_extent` — fixed item size for faster layout
- `divider_thickness` — draw dividers between items
- `auto_scroll` — keep the latest item in view (chat/logs)
- `reverse`
- `cache_extent`

## Usage

`list_view` expands to fill its parent — give it `expand: true` inside a
`column`, or a fixed `height`. For huge or streamed lists, set
`build_controls_on_demand: true`.
