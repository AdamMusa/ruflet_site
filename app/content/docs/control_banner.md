# Banner

A message at the top of the page with one or more actions, for important
states the user should act on, such as being offline. It stays until the user
or your code dismisses it.

## Example

```ruby
status = text(value: "Online")
offline = banner(
  text("You are offline. Changes are saved on this device."),
  leading: icon("wifi_off", color: "#92400e"),
  bgcolor: "#fef3c7",
  actions: [
    text_button("Retry", on_click: ->(_event) {
      page.close_banner
      page.update(status, value: "Reconnecting…")
    }),
    text_button("Dismiss", on_click: ->(_event) { page.close_banner })
  ]
)
page.add(column(children: [status, button("Go offline", on_click: ->(_event) { page.show_banner(offline) })]))
```

## Common properties

- `content` — required; the message, usually a `text`; the first positional argument sets it
- `actions` — buttons shown with the message
- `leading` — an icon or other control before the message
- `bgcolor` / `elevation` / `divider_color`
- `content_text_style` / `content_padding`
- `force_actions_below` — put the actions under the message
- `leading_padding` / `min_action_bar_height` / `shadow_color` / `margin`
- `on_visible` — the banner was shown
- `on_dismiss` — the banner was closed. On iOS and macOS, the 0.0.23 client never sends it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

`page.show_banner(banner)` mounts and opens the banner, and `page.close_banner`
closes it. Tapping an action does not close the banner, so call
`page.close_banner` in the action's handler, as the example does. A banner
needs `content` and at least one action; without an action the client shows
an error box instead. See [Navigation and Feedback](/docs/navigation-feedback)
for snackbars and dialogs, which suit short-lived messages better.

On iOS and macOS the banner is drawn over the top of the screen with its
actions as Cupertino buttons below the message. It uses `content`,
`actions`, `leading`, `bgcolor` and `content_padding` (16 on every side by
default); `elevation`, `divider_color`, `content_text_style`,
`force_actions_below`, `leading_padding`, `min_action_bar_height`,
`shadow_color`, `surface_tint_color` and `margin` apply on Android, web,
Windows and Linux only.

`surface_tint_color` tints the banner by its elevation. The 0.0.23 client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
