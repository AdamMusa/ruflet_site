# ListTile

A single fixed-height row with optional leading/trailing controls, a title, and
a subtitle — the building block of lists and menus. Android, web, Windows and
Linux draw a Material list row; iOS and macOS draw an iOS list row.

## Example

```ruby
profile = text("Profile closed")
open_profile = ->(_event) { page.update(profile, value: "Profile opened") }
page.add(
  column(
    children: [
      list_tile(
        leading: icon("person"),
        title: text("Ada Lovelace"),
        subtitle: text("Engineer"),
        trailing: icon_button("chevron_right", on_click: open_profile),
        on_click: open_profile
      ),
      profile
    ]
  )
)
```

## Common properties

- `title`
- `subtitle`
- `leading` / `trailing`
- `dense` / `is_three_line` — Android, web, Windows and Linux only
- `content_padding`
- `bgcolor`
- `hover_color` — Android, web, Windows and Linux only
- `selected` / `selected_color` / `selected_tile_color` — iOS and macOS draw no selected colors; there `selected` only tells screen readers, and needs the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `shape` — Android, web, Windows and Linux only
- `url` — open a URL on tap
- `toggle_inputs` — a tap anywhere on the row toggles the `switch` or `checkbox` in it
- `chevron` — add a chevron after `trailing`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`title` is required: `list_tile` raises `ArgumentError` without it.

## Settings rows

On iOS and macOS, `additional_info` shows detail text before `trailing`, like
the value on the right of an iOS Settings row; Android, web, Windows and Linux
ignore it. With `toggle_inputs: true`, tapping anywhere on the row flips the
switch in it:

```ruby
status = text("Wi-Fi on")
wifi = switch(
  value: true,
  on_change: ->(event) { page.update(status, value: event.control.props["value"] ? "Wi-Fi on" : "Wi-Fi off") }
)
page.add(
  column(
    children: [
      list_tile(
        leading: icon("wifi"),
        title: text("Wi-Fi"),
        additional_info: text("Home"),
        trailing: wifi,
        toggle_inputs: true
      ),
      status
    ]
  )
)
```

On iOS and macOS, the 0.0.23 client toggles a `switch` or `checkbox` in the
row, but not a `radio`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

These apply on iOS and macOS only:

- `additional_info` — detail text before `trailing`; on Android, web, Windows and Linux put such text in `trailing`
- `bgcolor_activated` — the background while the row is pressed
- `notched` — the inset-grouped row style, with a larger leading area
- `leading_size` (default 28, or 30 when `notched`) and `leading_to_title` (default 16, or 12 when `notched`)

These apply on Android, web, Windows and Linux only:

- `horizontal_spacing`, `min_leading_width`, `min_vertical_padding`, `min_height`, `visual_density`, `style` and `title_alignment` — the Material row layout
- `icon_color`, `text_color`, `selected_color`, `selected_tile_color`, `splash_color` and `focus_color`
- `title_text_style`, `subtitle_text_style` and `leading_and_trailing_text_style`
- `autofocus`, `enable_feedback` and `mouse_cursor`

On iOS and macOS the row keeps the colors and text styles of the controls you
put in it, so style a `text` title directly when you need a color there.
`on_long_press` fires on iOS and macOS only with the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`cupertino_list_tile` sends the same `ListTile` control, so it is drawn the
same way on every platform. See
[CupertinoListTile](/docs/control-cupertino-list-tile).

With 0.0.23 pad a row with `list_tile(content_padding: 16)`:
`cupertino_list_tile` has no `content_padding`, and its `padding` keyword
takes effect only with the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

`list_tile` is commonly the child of a [`list_view`](/docs/control-list-view) or
[`column`](/docs/control-column):

```ruby
column(children: people.map { |p| list_tile(title: text(p.name)) })
```

To group rows in sections with a header and a footer, use
[`list_section`](/docs/control-list-section).
