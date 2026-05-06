# AlertDialog

A Material modal dialog for confirmation and information flows.

## Example

```ruby
dialog = nil
dialog = alert_dialog(
  open: false,
  modal: true,
  title: text(value: "Hello"),
  content: text(value: "Hello from Ruflet"),
  actions: [
    text_button(
      content: text(value: "OK"),
      on_click: ->(_e) { page.update(dialog, open: false) }
    )
  ]
)
```

## Common properties

- `open`
- `modal`
- `title`
- `content`
- `actions`
- `icon`
- `bgcolor`
- `on_dismiss`

## Usage

Show the dialog with:

```ruby
page.show_dialog(dialog)
```

## Notes

- `actions` takes an array of controls
- `title` and `content` are usually `text(...)` controls
