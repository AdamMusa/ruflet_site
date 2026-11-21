# BottomSheet

A panel that slides up from the bottom of the screen. Show it with
`page.show_bottom_sheet`.

## Example

```ruby
status = text("Link not copied")
sheet = nil
sheet = bottom_sheet(
  show_drag_handle: true,
  clip_behavior: "antiAlias",
  content: container(
    padding: 24,
    bgcolor: :surfacecontainerlow,
    content: column(
      tight: true,
      spacing: 12,
      children: [
        text(value: "Share", style: { size: 18, weight: "w700" }),
        filled_button(content: text("Copy link"), on_click: ->(_e) {
          page.close_bottom_sheet(sheet)
          page.update(status, value: "Link copied")
        })
      ]
    )
  )
)

page.add(
  column(
    children: [
      status,
      button("Share", on_click: ->(_e) { page.show_bottom_sheet(sheet) })
    ]
  )
)
```

`:surfacecontainerlow` is the color the Material sheet itself uses, so the
container looks the same there. On iOS and macOS it is the page's background
color, and with 0.0.23 it is the only background the content gets (see
[iOS and macOS](#ios-and-macos)). Write theme color names without
underscores: a name such as `:surface_container_low` matches no color, so the
container would draw no background.

`show_bottom_sheet` opens the sheet for you. You can also assign
`page.bottom_sheet = bottom_sheet(open: true, …)` directly, but the assignment
form only displays when the control is built with `open: true`.

`page.close_bottom_sheet` closes the currently shown sheet. Pass a sheet when
you want to close a specific instance: `page.close_bottom_sheet(sheet)`.
`show_bottomsheet` and `close_bottomsheet` are compact aliases.

## Common properties

- `content` — the sheet's child control
- `open` — show / hide
- `dismissible` — tap outside to close (default `true`)
- `barrier_color` — the dimmed backdrop behind the sheet
- `bgcolor`
- `shape` / `elevation` — Android, web, Windows and Linux only
- `clip_behavior` / `animation_style` — Android, web, Windows and Linux only
- `padding` / `height` — iOS and macOS only; see below
- `scrollable` / `size_constraints` / `maintain_bottom_view_insets_padding` — let a tall sheet grow past 9/16 of the screen height up to the status bar, limit its size (`{ max_width: 640 }`), and lift the content above the on-screen keyboard (default `true`); on iOS and macOS these need the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `draggable` / `show_drag_handle` / `use_safe_area` / `fullscreen` — on iOS and macOS these need the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`draggable` lets the user drag the sheet down to close it (default `false`),
`show_drag_handle` adds a grabber at the top, `use_safe_area` keeps the
content clear of the status bar and the home indicator (default `true`), and
`fullscreen` opens the sheet at full height.

## iOS and macOS

On iOS and macOS, `picker`, `timer_picker` and `date_picker` content is shown
on a fixed panel with `bgcolor` (the system background color by default) and
`padding`, 220 high unless you set `height`.

With 0.0.23 other content is shown without a panel or background, so give it
its own, for example a `container` with a `bgcolor`. On `main` the client
draws every sheet as an iOS popup with rounded top corners on `bgcolor`, with
`padding` around the content and `height` as its height, and a `fullscreen`
sheet as a stacked page sheet that can be dragged down unless you pass
`draggable: false`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Prefer the page helper:

```ruby
page.close_bottom_sheet(sheet)
```

The lower-level equivalent is `page.update(sheet, open: false)`.

For a modal that hosts your *website* content (e.g. an auth flow), see
[Native Shell](/docs/rails-native-shell).
