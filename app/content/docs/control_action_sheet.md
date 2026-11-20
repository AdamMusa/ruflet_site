# ActionSheet

A short list of choices that slides up from the bottom of the screen, with an
optional title, message and Cancel button, such as the options for a photo.
Build each choice with
[`action_sheet_action`](/docs/control-action-sheet-action) and present the
sheet in a [`bottom_sheet`](/docs/control-bottom-sheet).

## Example

```ruby
status = text("No choice yet")
sheet = nil
choose = ->(label) {
  ->(_event) {
    page.close_bottom_sheet(sheet)
    page.update(status, value: "You chose #{label}")
  }
}

sheet = bottom_sheet(
  action_sheet(
    title: text("Photo"),
    message: text("What do you want to do with this photo?"),
    actions: [
      action_sheet_action("Share", default: true, on_click: choose.call("Share")),
      action_sheet_action("Save to Files", on_click: choose.call("Save to Files")),
      action_sheet_action("Delete", destructive: true, on_click: choose.call("Delete"))
    ],
    cancel: action_sheet_action("Cancel", on_click: ->(_event) { page.close_bottom_sheet(sheet) })
  )
)

page.add(
  column(
    children: [
      status,
      button("Photo options", on_click: ->(_event) { page.show_bottom_sheet(sheet) })
    ]
  )
)
```

Tapping an action does not close the sheet: close it in the action's
`on_click`, as above.

## Properties

- `title` — text at the top, as a string or a control.
- `message` — smaller text below the title, as a string or a control.
- `actions` — the `action_sheet_action` choices, from top to bottom.
- `cancel` — an `action_sheet_action` set apart below the others, for closing the sheet without choosing.

Give the sheet at least one action or a `cancel` action. On Android, web,
Windows and Linux a sheet with neither shows an error box.

## Actions

`action_sheet_action(content, **props)` takes its label as the first
argument or as `content:`, a string or a control.

- `default: true` — the default choice, shown in bold.
- `destructive: true` — a choice such as Delete, shown in red.
- `on_click` — the user tapped the action.
- `disabled: true` — the action does not fire `on_click`; Android, web, Windows and Linux also dim it.

## Platform differences

On iOS and macOS the sheet is drawn as an iOS action sheet: the actions form
one rounded group and `cancel` is a separate rounded button below it. An
action's `mouse_cursor` applies there only. With 0.0.23 the sheet floats over
the dimmed page, the way iOS shows its own action sheets.

With the next release, on iOS and macOS the `bottom_sheet` draws the action
sheet on its own panel, with rounded top corners in the sheet's `bgcolor`
(the system background by default). **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On Android, web, Windows and Linux the sheet is a column of list rows: the
title, the message, one row per action, then a divider and the `cancel` row.
The actions there ignore the common layout properties such as `width` and
`margin`.

`cupertino_action_sheet` and `cupertino_action_sheet_action` send the same
controls, so they are drawn the same way on every platform. See
[CupertinoActionSheet](/docs/control-cupertino-action-sheet).
