# ContextMenu

A menu that opens over a control when the user right-clicks it or presses and
holds it, such as Rename and Delete on a file. Wrap the control in
`context_menu` and give the entries as
[`context_menu_action`](/docs/control-context-menu-action)s.

## Example

```ruby
status = text(value: "Right-click or long-press the file")
page.add(
  column(
    children: [
      context_menu(
        container(content: text("notes.txt"), padding: 16, bgcolor: "#f1f5f9"),
        primary_trigger: "longPress",
        actions: [
          context_menu_action("Open", icon: "open_in_new", trailing_icon: "open_in_new", on_click: ->(_event) { page.update(status, value: "Opened notes.txt") }),
          context_menu_action("Delete", icon: "delete", trailing_icon: "delete", destructive: true, on_click: ->(_event) { page.update(status, value: "Deleted notes.txt") })
        ],
        on_dismiss: ->(_event) { page.update(status, value: "Menu closed") }
      ),
      status
    ]
  )
)
```

## Common properties

- `content` — the control the menu belongs to (required); the first positional argument sets it
- `actions` — the entries; every client reads this list for every trigger, so use it for a menu that must work everywhere
- `primary_trigger` / `secondary_trigger` / `tertiary_trigger` — what opens the menu with each mouse button: `"down"` (a click), `"longPress"` or `"disabled"`
- `primary_items` / `secondary_items` / `tertiary_items` — a different list for each mouse button
- `items` — the entries for `open`, and for a trigger whose own list is empty
- `on_select` / `on_dismiss` — the user picked an entry, or closed the menu without one
- `open` — open the menu from code

## Usage

Handle each entry's own `on_click`, as above. The menu's `on_select` fires
too, after the entry's handler; its `event.data` is a hash with symbol keys,
and `event.data[:idx]` is the chosen entry's position in the list shown.

By default a right-click opens the menu (`secondary_trigger: "down"`) and the
primary button does nothing (`primary_trigger: "disabled"`). Mouse triggers do
not respond to touch, so on Android phones the menu opens only from a long
press: set `primary_trigger: "longPress"`, as above. Spell the value
`"longPress"`: the 0.0.23 client does not read `"long_press"`.

Each mouse button can show its own list (`primary_items`, `secondary_items`,
`tertiary_items`). When the button's list is empty, the client falls back to
`items` and then to `actions`. With 0.0.23, on Android, web, Windows and
Linux, a click skips `items` and shows `actions`, and `items` is read only by
`open`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS the client draws the native context menu: a long press lifts
`content` above a blurred page and lists the entries under it, each with its
`trailing_icon`, in bold when `default` and in red when `destructive`; `icon`
and `checked` are not shown there. `enable_haptic_feedback: true` adds a
haptic tap. With 0.0.23 that menu shows `actions` (or `items`) and never fires
`on_select` or `on_dismiss`. On `main` it shows the list of the button the
long press stands for (`primary_items` when `primary_trigger` is
`"longPress"`, otherwise `secondary_items`), then `items`, then `actions`, and
fires both events. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`menu.open` shows the menu at the middle of `content` on Android, web,
Windows and Linux; the client does not read `position:` yet. On iOS and macOS
the native menu cannot be opened from code.

For an iOS-only menu, [`cupertino_context_menu`](/docs/control-cupertino-context-menu)
builds the same control with the iOS keywords only.
