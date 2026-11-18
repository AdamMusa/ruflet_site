# AnimatedSwitcher

Animates between its old and new `content` whenever you replace it: a fade by
default, or a scale or rotation.

## Example

```ruby
face = ->(label, color) {
  container(width: 160, height: 100, bgcolor: color, border_radius: 12, alignment: "center", content: text(label, size: 20))
}
front = true
card = animated_switcher(face.call("Front", "#bfdbfe"), duration: 300, reverse_duration: 300, transition: "scale")
page.add(
  column(
    children: [
      card,
      button("Flip", on_click: ->(_event) {
        front = !front
        page.update(card, content: front ? face.call("Front", "#bfdbfe") : face.call("Back", "#fde68a"))
      })
    ]
  )
)
```

## Common properties

- `content` — required; the control currently shown; the first positional argument sets it
- `transition` — `"fade"` (default), `"scale"` or `"rotation"`
- `duration` / `reverse_duration` — milliseconds for the new and the old content (each defaults to 1000)
- `switch_in_curve` / `switch_out_curve` — easing curves such as `"easeIn"` or `"easeOut"`

## Usage

Swap the content with `page.update(switcher, content: new_control)`. The
switcher animates every time it is rebuilt with new content.
