# BottomSheet

A panel that slides up from the bottom of the screen. Assign it to
`page.bottom_sheet` with `open: true` to show it.

## Example

```ruby
sheet = bottom_sheet(
  open: true,
  show_drag_handle: true,
  content: container(
    padding: 24,
    content: column(
      tight: true,
      spacing: 12,
      controls: [
        text("Share", size: 18, weight: "bold"),
        filled_button(content: text("Copy link"), on_click: ->(_e) { copy_link })
      ]
    )
  )
)

page.bottom_sheet = sheet
page.update
```

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
