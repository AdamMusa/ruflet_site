# PopupMenuButton

A button, usually a "more" icon, that opens a menu of
[`popup_menu_item`](/docs/control-popup-menu-item) entries.

## Example

```ruby
status = text(value: "Choose an action")
page.add(
  row(
    children: [
      status,
      popup_menu_button(
        [
          popup_menu_item("Rename", icon: "edit", on_click: ->(_event) { page.update(status, value: "Renaming") }),
          popup_menu_item("Duplicate", icon: "content_copy", on_click: ->(_event) { page.update(status, value: "Duplicated") }),
          popup_menu_item(),
          popup_menu_item("Pinned", checked: false, on_click: ->(event) { page.update(status, value: "Pinned: #{event.data}") })
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
above.
