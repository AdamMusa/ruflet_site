# SnackBar

A snackbar displays brief feedback over the current view.

## Example

Show a snackbar with `page.show_snack_bar`. It mounts the snackbar and opens it
for you:

```ruby
page.show_snack_bar(
  snack_bar(content: text("Profile saved"))
)
```

Add an action button. When `action` is a string, its button fires `on_action`:

```ruby
page.show_snack_bar(
  snack_bar(
    content: text("Item deleted"),
    action: "Undo",
    on_action: ->(_event) { restore_item },
    duration: 4000,
    show_close_icon: true
  )
)
```

You can also assign `page.snack_bar` directly, but the assignment form only
displays when you pass `open: true`:

```ruby
page.snack_bar = snack_bar(open: true, content: text("Profile saved"))
```

Prefer `page.show_snack_bar` — it opens the snackbar without the extra flag and
mirrors `page.show_dialog`, `page.show_bottom_sheet`, and `page.show_banner`.

## Properties

- `content` — required message control, such as `text("...")`.
- `action` — optional action button. A string is used as the button label; a
  `snack_bar_action(...)` control gives you full control over its styling.
- `duration` — how long the snackbar stays visible, in milliseconds.
- `show_close_icon` — show a close button.
- `behavior` — `"fixed"` or `"floating"`.
- `bgcolor`, `elevation`, `shape`, `margin`, and `padding` — presentation options.
- `open` — whether the snackbar is visible. `show_snack_bar` sets this; you only
  set it yourself when assigning `page.snack_bar` directly.

## Events

- `on_action` — fired when a string `action` button is selected.
- `on_dismiss` — fired when the snackbar closes.
- `on_visible` — fired when the snackbar becomes visible.
