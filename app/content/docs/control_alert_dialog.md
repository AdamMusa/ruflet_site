# AlertDialog

A modal dialog with a title, a message and a few buttons, for confirmations
and short decisions. Android, web, Windows and Linux show a Material dialog;
iOS and macOS show an iOS alert, and its buttons become iOS dialog actions.

## Example

```ruby
status = text("Draft saved")
deleted = false
confirm = nil
confirm = alert_dialog(
  modal: true,
  title: text("Delete this draft?"),
  content: text("You cannot undo this."),
  actions: [
    text_button("Cancel", on_click: ->(_event) { page.close_dialog(confirm) }),
    button("Delete", destructive: true, on_click: ->(_event) {
      deleted = true
      page.close_dialog(confirm)
    })
  ],
  on_dismiss: ->(_event) {
    page.update(status, value: deleted ? "Draft deleted" : "Draft kept")
  }
)

page.add(
  column(
    children: [
      status,
      button("Delete draft", on_click: ->(_event) { page.show_dialog(confirm) })
    ]
  )
)
```

## Usage

Show the dialog with:

```ruby
page.show_dialog(dialog)
```

`page.close_dialog(dialog)` closes that dialog, and `page.pop_dialog` closes
the latest open one. Tapping a button does not close the dialog by itself, so
close it in the button's handler. A tap outside the dialog closes it unless
you pass `modal: true`. `on_dismiss` fires after every close, however the
dialog was closed, and the dialog's `open` is `false` again.

The client shows an error box instead of the dialog when it has no `title`,
no `content` and no `actions`.

## Properties

These work on every platform:

- `title` — a string or a control
- `content` — the body, usually a `text` or a `column`
- `actions` — an array of buttons along the bottom
- `modal` — when `true`, a tap outside does not close the dialog (default `false`)
- `barrier_color` — the color of the dimmed backdrop
- `open` — whether the dialog is shown; `page.show_dialog` and `page.close_dialog` set it

On iOS and macOS each button in `actions` is drawn as an iOS dialog action:
`button(..., default: true)` shows it in bold and `destructive: true` in red.
Android, web, Windows and Linux ignore those two flags.

These apply on Android, web, Windows and Linux only:

- `icon`, `icon_color` and `icon_padding` — an icon above the title
- `bgcolor`, `elevation`, `shadow_color`, `shape` and `clip_behavior`
- `title_padding` and `title_text_style`, `content_padding` and `content_text_style`
- `actions_padding`, `actions_alignment`, `action_button_padding` and `actions_overflow_button_spacing`
- `inset_padding` — the space between the dialog and the screen edges
- `alignment` — where the dialog sits, as `{ x:, y: }` from -1.0 to 1.0
- `scrollable` — lets a long title and content scroll; the iOS alert scrolls its content by itself
- `semantics_label` — what screen readers announce when the dialog opens

This applies on iOS and macOS only:

- `inset_animation` — how the alert moves when the keyboard opens: `{ duration:, curve: }` or a number of milliseconds (default 100 ms, `"decelerate"`)

## Events

- `on_dismiss` — the dialog closed, whether the user tapped outside it or your code closed it.

## cupertino_alert_dialog

`cupertino_alert_dialog` sends the same `AlertDialog` control, so each
platform draws it like `alert_dialog`: an iOS alert on iOS and macOS and a
Material dialog on Android, web, Windows and Linux. Besides the common properties it accepts only `title`, `content`,
`actions`, `modal`, `barrier_color`, `inset_animation`, `open` and
`on_dismiss`. See [CupertinoAlertDialog](/docs/control-cupertino-alert-dialog).

## Notes

- `actions` takes an array of controls
- `title` and `content` are usually `text(...)` controls
- use `page.pop_dialog` to close the latest open dialog
