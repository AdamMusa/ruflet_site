# SnackBar

A transient message shown for brief feedback.

## Example

```ruby
page.snack_bar = snack_bar(
  content: text(value: "Profile saved")
)
page.snack_bar.open = true
page.update
```

## Common properties

- `content`
- `action`
- `bgcolor`
- `open`

## Usage

```ruby
elevated_button(
  content: text(value: "Save"),
  on_click: ->(_e) do
    page.snack_bar = snack_bar(content: text(value: "Saved"))
    page.snack_bar.open = true
    page.update
  end
)
```

## Notes

- A snack bar is usually assigned to `page.snack_bar`
