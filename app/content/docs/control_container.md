# Container

A single-child layout surface for spacing, sizing, alignment, and decoration.

## Example

```ruby
container(
  padding: 16,
  margin: 12,
  border_radius: 12,
  bgcolor: "#111827",
  content: text(value: "Card content")
)
```

## Common properties

- `content`
- `padding`
- `margin`
- `width`
- `height`
- `expand`
- `bgcolor`
- `border`
- `border_radius`
- `alignment`
- `on_click`

## Usage

Use `container` when a control needs its own box, spacing, or click surface:

```ruby
container(
  expand: true,
  alignment: "center",
  content: text(value: "Centered")
)
```

## Decoration

- `bgcolor`, `gradient` and `image` — the background: a color, a gradient hash such as `{ _type: "linear", colors: ["#2563eb", "#7c3aed"] }`, or `{ src:, fit:, opacity: }` for an image
- `border` and `border_radius` — `border_radius` also clips the content to the rounded corners
- `shape` — `"rectangle"` (default) or `"circle"`
- `shadow` — `{ color:, offset: { x:, y: }, blur_radius:, spread_radius: }`, or a list of them
- `foreground_decoration` — the same kind of decoration painted over the content, such as a translucent veil
- `blur` — blurs what is behind the container, for frosted glass: a sigma such as `10`
- `color_filter` — tints the container and its content: `{ color:, blend_mode: }`

```ruby
page.add(
  stack(
    width: 320,
    height: 200,
    children: [
      image("https://picsum.photos/id/1018/640/400", width: 320, height: 200, fit: "cover"),
      container(
        left: 16,
        right: 16,
        bottom: 16,
        padding: 12,
        border_radius: 12,
        blur: 10,
        bgcolor: "#66ffffff",
        shadow: { color: "#33000000", offset: { x: 0, y: 4 }, blur_radius: 12 },
        content: text("Mountain lake", style: { size: 18, weight: "bold" })
      )
    ]
  )
)
```

## Clicks and animation

- `on_click`, `on_long_press` and `url` make the container tappable.
- `on_tap_down` — `event.local_position` and `event.global_position` give the point where the press started.
- `on_hover` — `event.data` is `true` when the pointer enters. On leave the client sends `false`, which arrives in Ruby as `nil`, so test `event.data == true`.
- `ink: true` — touch feedback on a tappable container: an ink ripple on Android, web, Windows and Linux, colored by `ink_color`; on iOS and macOS the pressed container fades to 40% opacity instead.
- `opacity_on_click` — the opacity an `ink: true` container fades to on iOS and macOS. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `ignore_interactions: true` — the container and its content ignore taps.
- `animate` — animates changes to size, padding, colors and decoration: `true` (1000 ms), a duration in milliseconds, or `{ duration: 300, curve: "easeOut" }`. `on_animation_end` then gets `"container"` in `event.data`.

```ruby
expanded = false
panel = container(
  width: 160,
  height: 80,
  padding: 12,
  bgcolor: "#dbeafe",
  border_radius: 12,
  animate: { duration: 300, curve: "easeOut" },
  content: text("Tap to grow"),
  on_click: ->(_event) {
    expanded = !expanded
    page.update(panel, width: expanded ? 280 : 160, height: expanded ? 160 : 80, bgcolor: expanded ? "#bfdbfe" : "#dbeafe")
  }
)

page.add(panel)
```

`theme`, `dark_theme` and `theme_mode` give the controls inside the container
their own theme, in the same form as the page's.

## Notes

- `container` takes one nested child through `content:`
- `alignment: "center"` is normalized by Ruflet for convenience; other alignments are `{ x:, y: }` hashes from -1 to 1
- On Ruflet main `alignment` also takes other names, such as `"top_left"` or `"bottom_right"`. A 0.0.23 client shows an error in place of the container for them. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `padding` and `margin` take one number or a hash of sides, `{ left:, top:, right:, bottom: }`; `border_radius` takes one number or a hash of corners, `{ top_left:, top_right:, bottom_left:, bottom_right: }`. A side or corner you leave out is 0.
- On Ruflet main those hashes can also give `all:` for every side or corner they do not name, such as `padding: { all: 16, bottom: 0 }`. A 0.0.23 client reads `all:` as 0. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
