# FloatingActionButton

A round button that floats over the page for its main action, such as New
message. Build it with `fab` (or `floating_action_button`) and assign it to
`page.floating_action_button`.

## Example

```ruby
count = 0
count_text = text(count.to_s, style: { size: 40 })

page.floating_action_button = fab(
  icon: "add",
  tooltip: "Add one",
  on_click: ->(_event) do
    count += 1
    page.update(count_text, value: count.to_s)
  end
)
page.add(
  container(
    expand: true,
    alignment: Ruflet::MainAxisAlignment::CENTER,
    content: count_text
  )
)
```

## Common properties

- positional content: `fab("Create")` — a label; with `icon:` too, the button is wide with the icon before the label
- `icon` — an icon name or an `icon(...)` control; give `icon`, a label, or both
- `bgcolor` / `foreground_color` — the fill and the icon and label color
- `mini` — a smaller, 40-point button
- `tooltip`
- `on_click`
- `url` — open a link on click
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

`page.add` takes one control, so assign the button to
`page.floating_action_button` and add the page content separately, as above.
With `page.views`, give each `view` its own `floating_action_button:`.
`page.floating_action_button_location` moves it, for example
`"centerFloat"`, `"endTop"` or `"centerDocked"` (docked into a
[`bottom_app_bar`](/docs/control-bottom-app-bar) with a notch shape). Spell
locations in camel case: the 0.0.23 client does not read `"center_docked"`.

`fab` accepts these forms:

- `fab("Create")`
- `fab(icon: "add")`
- `fab("Create", icon: "add")`
- `fab(icon: Ruflet::MaterialIcons::ADD)`

Use `url:` to open a link through the client's URL launcher, or `on_click:` for
application actions, not both on one button.

On iOS and macOS the client draws a round iOS button that uses `icon`, the
label, `mini`, `bgcolor` and `foreground_color`. `shape`, `elevation` and the
other elevations, `hover_color`, `focus_color`, `splash_color`,
`clip_behavior`, `enable_feedback`, `mouse_cursor` and `autofocus` apply on
Android, web, Windows and Linux only.
