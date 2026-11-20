# PageView

A horizontally swipeable set of full-size pages, for onboarding screens,
galleries and step-by-step content. Each child control is one page.

## Example

```ruby
colors = ["#dbeafe", "#dcfce7", "#fef3c7"]
position = text(value: "Page 1 of 3")
page.add(
  column(
    expand: true,
    children: [
      page_view(
        colors.each_with_index.map { |color, index|
          container(bgcolor: color, alignment: "center", content: text("Slide #{index + 1}", size: 28))
        },
        expand: true,
        on_change: ->(event) { page.update(position, value: "Page #{event.data.to_i + 1} of 3") }
      ),
      position
    ]
  )
)
```

## Common properties

- `controls` — the pages; the first positional argument sets them
- `selected_index` — the page shown first
- `horizontal` — swipe sideways (default) or, when `false`, up and down
- `viewport_fraction` — the share of the viewport each page fills; below `1.0` the neighbours peek in
- `pad_ends` / `snap` / `keep_page` / `reverse`
- `on_change` — `event.data` is the index of the page now shown
- `next_page`, `previous_page`, `jump_to_page` and `go_to_page` methods, and the `animation_duration` / `animation_curve` they use. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Give the page view a bounded size: `expand: true` inside an expanded `column`,
as above, or a fixed `height`.
