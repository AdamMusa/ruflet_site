# BottomSheet

A panel that slides up from the bottom of the screen. Show it with
`page.show_bottom_sheet`.

## Example

```ruby
sheet = bottom_sheet(
  show_drag_handle: true,
  content: container(
    padding: 24,
    content: column(
      tight: true,
      spacing: 12,
      children: [
        text(value: "Share", style: { size: 18, weight: "w700" }),
        filled_button(content: text("Copy link"), on_click: ->(_e) { copy_link })
      ]
    )
  )
)

page.show_bottom_sheet(sheet)

# Later, from an event handler:
page.close_bottom_sheet
```

`show_bottom_sheet` opens the sheet for you. You can also assign
`page.bottom_sheet = bottom_sheet(open: true, …)` directly, but the assignment
form only displays when the control is built with `open: true`.

`page.close_bottom_sheet` closes the currently shown sheet. Pass a sheet when
you want to close a specific instance: `page.close_bottom_sheet(sheet)`.
`show_bottomsheet` and `close_bottomsheet` are compact aliases.

## Common properties

- `content` — the sheet's child control
- `open` — show / hide
- `dismissible` — tap outside to close
- `draggable`
- `show_drag_handle`
- `bgcolor`
- `shape`
- `elevation`
- `use_safe_area`
- `fullscreen`

## Usage

Prefer the page helper:

```ruby
page.close_bottom_sheet(sheet)
```

The lower-level equivalent is `page.update(sheet, open: false)`.

For a modal that hosts your *website* content (e.g. an auth flow), see
[Native Shell](/docs/rails-native-shell).
