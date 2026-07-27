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
```

`show_bottom_sheet` opens the sheet for you. You can also assign
`page.bottom_sheet = bottom_sheet(open: true, …)` directly, but the assignment
form only displays when the control is built with `open: true`.

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

Close it by setting `open: false` and updating:

```ruby
page.update(sheet, open: false)
```

For a modal that hosts your *website* content (e.g. an auth flow), see
[Webview Apps](/docs/rails-webview-apps).
