# MenuBar

A desktop-style bar of menus, such as File and Edit. Each menu is a
[`submenu_button`](/docs/control-submenu-button) whose entries are
[`menu_item_button`](/docs/control-menu-item-button)s, nested submenus and
`divider`s.

## Example

```ruby
status = text(value: "No document")
page.add(
  column(
    children: [
      menu_bar([
        submenu_button(
          [
            menu_item_button("New", leading: icon("note_add"), on_click: ->(_event) { page.update(status, value: "New document") }),
            menu_item_button("Open", leading: icon("folder_open"), on_click: ->(_event) { page.update(status, value: "Opened a document") }),
            divider(),
            menu_item_button("Quit", on_click: ->(_event) { page.update(status, value: "Bye") })
          ],
          content: "File"
        ),
        submenu_button(
          [menu_item_button("About", on_click: ->(_event) { page.update(status, value: "Ruflet demo") })],
          content: "Help"
        )
      ]),
      status
    ]
  )
)
```

## Common properties

- `controls` — the menus, left to right; the first positional argument sets them
- `style` — the bar's background, elevation and padding, for example `{ bgcolor: "#f8fafc", elevation: 0 }`
- `clip_behavior`

Each `submenu_button` takes its entries as the first argument and its label as
`content:`; each `menu_item_button` takes its label as the first argument and
runs `on_click`. An entry without an `on_click` handler is drawn disabled.

## Usage

On Android, web, Windows and Linux the bar is a Material menu bar: a menu drops
down under its button, a nested submenu opens beside it, and the keyboard
moves through the entries. `style` and `clip_behavior` apply there only.

On iOS and macOS the bar is a plain strip of buttons with a separator line.
Tapping a submenu opens its entries as a sheet from the bottom of the screen,
and picking an entry runs its `on_click`. Keep each menu one level deep there:
nested submenus are for Android, web, Windows and Linux.

On iOS and macOS, picking an entry also closes the sheet and fires the
submenu's `on_close`, and a disabled entry ignores taps. With 0.0.23 the sheet
stays open after the user picks an entry that has `on_click`, until the user
taps outside it, and a tap on a disabled entry still runs its `on_click` and
closes the sheet. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Keep menu bars for wide, pointer-driven layouts. On phones, a
[`popup_menu_button`](/docs/control-popup-menu-button) in the app bar or a
[`navigation_drawer`](/docs/control-navigation-drawer) usually fits better.
