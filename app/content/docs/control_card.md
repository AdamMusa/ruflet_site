# Card

A material card — an elevated, rounded surface that groups related content.

## Example

```ruby
card(
  elevation: 2,
  content: container(
    padding: 16,
    content: column(
      spacing: 8,
      controls: [
        text("Monthly report", size: 18, weight: "bold"),
        text("Revenue is up 12% over last month."),
        filled_button(content: text("Open"), on_click: ->(_e) { open_report })
      ]
    )
  )
)
```

## Common properties

- `content` — the card's child control
- `elevation`
- `bgcolor`
- `shape`
- `shadow_color`
- `clip_behavior`
- `margin`
- `variant` — `"elevated"`, `"filled"`, or `"outlined"`

## Usage

A card wraps a single `content` control — compose a `column`/`row` inside it for
multiple children, and pad with a `container` for inner spacing.
