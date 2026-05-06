# TextButton

A low-emphasis text action button.

## Example

```ruby
text_button(
  content: text(value: "Cancel"),
  on_click: ->(_e) { page.go("/") }
)
```

## Common properties

- `content`
- `on_click`
- `disabled`
- `style`

## Usage

```ruby
row(
  spacing: 8,
  children: [
    text_button(content: text(value: "Skip")),
    elevated_button(content: text(value: "Next"))
  ]
)
```

## Notes

- `text_button` is useful for secondary actions
