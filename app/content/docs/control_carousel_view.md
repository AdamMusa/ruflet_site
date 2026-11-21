# CarouselView

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A Material 3 carousel: a row of items that shrink as they scroll off the edge.
iOS clients scroll rounded, fixed-width items instead.

## Example

```ruby
status = text(value: "Tap a photo")
photos = (10..17).map { |id| "https://picsum.photos/id/#{id}/600/400" }

gallery = carousel_view(
  photos.map { |src| image(src, fit: "cover") },
  height: 200,
  item_extent: 280,
  shrink_extent: 120,
  item_snapping: true,
  on_item_click: ->(event) { page.update(status, value: "Photo #{event.data.to_i + 1}") }
)

page.add(
  column(
    children: [
      gallery,
      status,
      text_button(content: text("First photo"), on_click: ->(_event) { gallery.animate_to_item(0) })
    ]
  )
)
```

Every carousel needs `item_extent` or `flex_weights`. Give the items as the
first argument, as `children:`, or in a block.

## Layouts

- `item_extent` — every item is this many pixels wide. On Material, items at the edges shrink down to `shrink_extent`.
- `flex_weights` — a weighted layout such as `[1, 7, 1]` for one large item between two small ones. It wins over `item_extent`.
- `consume_max_weight` — with `flex_weights`, let items grow to the largest weight as they scroll in (default `true`); `false` keeps the layout fixed.

`shrink_extent` and `consume_max_weight` apply on Android, web, Windows and
Linux only: the iOS carousel does not shrink or grow its items.

## Properties

- `horizontal` — scroll horizontally (default `true`); `false` scrolls vertically.
- `reverse`, `item_snapping` and `initial_item` — scrolling behavior and the first visible item.
- `padding` — space around each item.
- `bgcolor`, `elevation`, `shape`, `overlay_color`, `enable_splash` and `item_clip_behavior` — item appearance.

## Events and methods

- `on_item_click` — the user tapped an item. `event.data` is its index.
- `animate_to_item(index, duration: 300, curve: "ease")` — scroll the mounted carousel so that item leads, as the "First photo" button above does.
