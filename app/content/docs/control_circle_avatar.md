# CircleAvatar

A circle that shows a user's photo, initials or an icon. When the photo cannot
load, the avatar keeps showing its `content`.

## Example

```ruby
note = text(value: "")
page.add(
  row(
    spacing: 12,
    children: [
      circle_avatar(text("AL"), bgcolor: "#bfdbfe", color: "#1e3a8a"),
      circle_avatar(icon("person"), radius: 24),
      circle_avatar(
        text("GH"),
        foreground_image_src: "https://avatars.githubusercontent.com/u/9919?s=96",
        radius: 24,
        on_image_error: ->(_event) { page.update(note, value: "Photo unavailable, showing initials") }
      ),
      note
    ]
  )
)
```

## Common properties

- `content` — usually `text` initials or an `icon`; the first positional argument sets it
- `foreground_image_src` — the photo, drawn over `content`
- `background_image_src` — an image drawn behind `content`
- `bgcolor` / `color` — background and content colors; on iOS and macOS `color` applies to text content only, not to an `icon`
- `radius`, or `min_radius` / `max_radius`
- `on_image_error` — an image failed to load; `event.data` is `"foreground"` or `"background"`, naming the image

## Usage

Give the avatar initials as `content` and the photo as `foreground_image_src`,
as in the third avatar above: the initials stay visible while the photo loads
or if it fails.
