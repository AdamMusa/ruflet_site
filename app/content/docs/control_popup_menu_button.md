# PopupMenuButton

A button, usually a "more" icon, that opens a menu of
[`popup_menu_item`](/docs/control-popup-menu-item) entries.

## Example

```ruby
status = text(value: "Choose an action")
pinned = false
page.add(
  row(
    children: [
      status,
      popup_menu_button(
        [
          popup_menu_item("Rename", icon: "edit", on_click: ->(_event) { page.update(status, value: "Renaming") }),
          popup_menu_item("Duplicate", icon: "content_copy", on_click: ->(_event) { page.update(status, value: "Duplicated") }),
          popup_menu_item("Pinned", checked: pinned, on_click: ->(event) {
            pinned = !pinned
            page.update(event.control, checked: pinned)
            page.update(status, value: pinned ? "Pinned" : "Unpinned")
          })
        ],
        icon: "more_vert",
        tooltip: "More actions"
      )
    ]
  )
)
```

## Common properties

- `items` — the `popup_menu_item(...)` entries; the first positional argument sets them
- `icon` / `icon_size` / `icon_color` — the button's icon (a "more" icon by default)
- `content` — a control to show instead of the icon
- `tooltip`
- `menu_position` / `menu_padding`
- `bgcolor` / `elevation` / `shape` — the menu's surface
- `on_open` / `on_cancel` — the menu opened, or closed without a choice

## Usage

Handle each item's own `on_click`. The button's `on_select` reports the chosen
item's internal id, which is rarely useful, so act in the item handlers as
above. A `checked` item keeps its check mark until you update `checked`, so
hold the state in Ruby, as the "Pinned" item does.

On iOS and macOS the menu opens as a Cupertino sheet that shows only each
item's `content` (its text): no `icon` and no check mark. An item without
`content`, such as a `popup_menu_item()` divider, draws an error box there, so
give every item text when the app runs on Apple platforms. `icon_size`,
`icon_color`, `menu_position`, `menu_padding`, `bgcolor`, `elevation` and
`shape` apply on Android, web, Windows and Linux only.

On iOS and macOS, the button fires `on_select` when an item is chosen and
`on_cancel` when the sheet closes without a choice. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
