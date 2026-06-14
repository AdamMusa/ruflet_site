# SnackBar

A snackbar displays brief feedback over the current view.

## Example

```ruby
page.snack_bar = snack_bar(
  open: true,
  content: text("Profile saved")
)
```

## Properties

- `content` — required message control.
- `open` — whether the snackbar is visible.
- `action` — optional action control.
- `duration` — display duration.
- `bgcolor`, `shape`, `margin`, and `padding` — presentation options.
- `show_close_icon` — show a close action.

## Events

- `on_action` — fired when the action is selected.
- `on_dismiss` — fired when the snackbar closes.
- `on_visible` — fired when the snackbar becomes visible.

Assigning `page.snack_bar` mounts and displays the snackbar. Ruflet replaces an
existing snackbar when another is assigned.
