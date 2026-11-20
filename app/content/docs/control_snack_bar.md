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
- `duration` — how long the snackbar stays visible, in milliseconds (default 4000).
- `persist` — keep the snackbar open after `duration` until the user taps its action or close button.
- `show_close_icon` — show a close button.
- `behavior` — `"fixed"` (default) or `"floating"`. Only a floating snackbar uses `margin` and `width`.
- `bgcolor`, `elevation`, `shape`, `margin`, and `padding` — presentation options.
- `open` — whether the snackbar is visible. `show_snack_bar` sets this; you only
  set it yourself when assigning `page.snack_bar` directly.

A `snack_bar_action` takes its label as the first argument and fires its own
`on_click`. Its `text_color` and `bgcolor` color the button, and
`disabled_text_color` and `disabled_bgcolor` color it after it has been
pressed, since an action works only once:

```ruby
status = text("Message archived")
page.add(status)
page.show_snack_bar(
  snack_bar(
    content: text("Message archived"),
    action: snack_bar_action(
      "Undo",
      text_color: :amber300,
      on_click: ->(_event) { page.update(status, value: "Message restored") }
    )
  )
)
```

## Events

- `on_action` — fired when a string `action` button is selected.
- `on_dismiss` — fired when the snackbar closes.
- `on_visible` — fired when the snackbar becomes visible.

## Closing

On Android, web, Windows and Linux a snackbar with an `action` stays open
until the user taps the action or the close button, unless you pass
`persist: false`; one without an action closes after `duration`. Tapping the
action closes it. The user can also swipe it away, by default downwards; set
`dismiss_direction`, for example `"horizontal"`.

On iOS and macOS every snackbar closes after `duration` unless you pass
`persist: true`, and tapping the action does not close it. It cannot be
swiped away.

On iOS and macOS a snackbar that closed by itself, after `duration` or from
its close button, does not open again: showing the same `snack_bar` a second
time does nothing there. Pass a new `snack_bar` to each `show_snack_bar` call,
as the examples above do.

`on_dismiss` fires when the snackbar closes on its own: after `duration`, a
swipe, or a tap on the action or the close button. On Android, web, Windows
and Linux it also fires when your code closes the snackbar or another
snackbar replaces it.

## Platform differences

On iOS and macOS the snackbar is a rounded bar that floats near the bottom of
the screen, on the system gray by default. It uses `content`, `action`,
`show_close_icon`, `bgcolor`, `padding`, `margin`, `width`, `duration` and
`persist`, and a `snack_bar_action`'s label, `disabled` and `on_click`.
`behavior`, `elevation`, `shape`, `clip_behavior`, `close_icon_color`,
`dismiss_direction` and `action_overflow_threshold` apply on Android, web,
Windows and Linux only, and so do a `snack_bar_action`'s colors.
