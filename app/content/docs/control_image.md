# Image

Render local, remote, or generated images.

## Example

```ruby
image(
  "https://picsum.photos/320/180",
  width: 320,
  height: 180
)
```

## Common properties

- positional source
- `src`
- `width`
- `height`
- `fit`
- `border_radius`
- `placeholder_src`

## Usage

```ruby
image(
  "assets/icon.png",
  width: 96,
  height: 96
)
```

## Sources

`src` takes a URL, a path in the app's assets, a Base64 string or bytes. A
Base64 string in `src` works with every release.
`src_base64:` is the same data under its own name; the 0.0.23 client ignores
it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

```ruby
# A 1x1 PNG, tinted and scaled up.
dot = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
page.add(image(dot, width: 48, height: 48, color: "#2563eb", color_blend_mode: "srcIn"))
```

## Loading and errors

- `placeholder_src` — an image shown while `src` loads; `placeholder_fit` sizes it.
- `fade_in_animation` / `placeholder_fade_out_animation` — fade the image in and the placeholder out: `true` (1000 ms), a duration in milliseconds, or `{ duration: 300, curve: "easeOut" }`.
- `error_content` — a control shown instead of the image when it fails to load.
- `gapless_playback` — keep the old image on screen while a new `src` loads.

```ruby
page.add(
  image(
    "https://picsum.photos/id/1039/640/360",
    width: 320,
    height: 180,
    fit: "cover",
    border_radius: 12,
    placeholder_src: "https://picsum.photos/id/1039/32/18",
    fade_in_animation: 300,
    error_content: container(width: 320, height: 180, bgcolor: "#e5e7eb", alignment: "center", content: icon("broken_image"))
  )
)
```

## Appearance

- `fit` — `"contain"`, `"cover"`, `"fill"`, `"fitWidth"`, `"fitHeight"`, `"scaleDown"` or `"none"`.
- `repeat` — tile a small image: `"repeat"`, `"repeatX"` or `"repeatY"`.
- `color` with `color_blend_mode` — tint the image, for example `color: "#2563eb", color_blend_mode: "srcIn"` for a one-color icon.
- `filter_quality` and `anti_alias` — scaling quality and edge smoothing.
- `cache_width` / `cache_height` — decode large photos at a smaller size to save memory.
- `semantics_label` / `exclude_from_semantics` — what screen readers say, or nothing for a decorative image.

`x`, `y` and `paint` apply only when the image is a shape inside a
[`canvas`](/docs/control-canvas); an image on the page ignores them.

## Notes

- Use local assets for app icons and packaged images
