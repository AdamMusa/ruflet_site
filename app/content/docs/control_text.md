# Text

Display labels, headings, counters, and inline status values.

## Example

```ruby
text(value: "Dashboard", style: { size: 28, weight: "w700" })
```

## Common properties

- positional value: `text("Hello")`
- keyword value: `text(value: "Hello")`
- `style`
- `selectable`

## Usage

```ruby
title = text(value: "Ruflet", style: { size: 28, weight: "w700" })
subtitle = text("Ruby UI on top of Flet")
```

## Notes

Common `style` keys used in Ruflet examples:

- `size`
- `weight`
- `color`
