# CustomScrollView

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A scroll view built from slivers: a collapsing app bar, lists, grids, sticky
section headers, single boxes and a filler that all scroll as one.

## Example

```ruby
photos = (10..21).map { |id| "https://picsum.photos/id/#{id}/200" }
contacts = %w[Ada Grace Linus Matz]

page.add(
  custom_scroll_view(
    [
      sliver_app_bar(title: text("Library"), variant: "medium"),
      sliver_to_box_adapter(
        container(padding: 16, content: text("Recent photos"))
      ),
      sliver_padding(
        [sliver_grid(photos.map { |src| image(src, fit: "cover") }, runs_count: 3)],
        padding: 8
      ),
      sliver_list(
        contacts.map { |name| list_tile(title: text(name)) },
        header: container(padding: 12, bgcolor: :surfacecontainerhigh, content: text("Contacts")),
        sticky_header: true
      ),
      sliver_fill_remaining(
        container(padding: 16, content: text("End of library"))
      )
    ],
    expand: true
  )
)
```

Give the slivers as the first argument, as `slivers:`, or in a block. A plain
control among them, such as a `container`, scrolls as a single box.

## Slivers

- [`sliver_app_bar`](/docs/control-sliver-app-bar) — an app bar that collapses, pins or floats as the view scrolls.
- `sliver_list(children, **props)` — a list. Takes `spacing`, `divider_thickness`, `item_extent`, `padding`, `bgcolor`, and a `header` that stays at the top while its items scroll under it when `sticky_header: true`.
- `sliver_grid(children, **props)` — a grid. Takes `runs_count` or `max_extent`, `spacing`, `run_spacing`, `child_aspect_ratio`, `padding`, `bgcolor`, `header` and `sticky_header`.
- `sliver_to_box_adapter(content)` — one ordinary control.
- `sliver_fill_remaining(content, has_scroll_body:, fill_overscroll:)` — fills the space left in the viewport after the other slivers.
- `sliver_padding(slivers, padding:)` — insets one or more slivers. A plain control among them scrolls as a box.

Sliver children take `key`, `data`, `visible` and their own keywords only;
other keywords raise ArgumentError.

## Properties

- `slivers` — the slivers, in scroll order.
- `horizontal` and `reverse` — scroll direction (both default `false`).
- `anchor` — where the zero scroll offset sits in the viewport, from 0 (the start, default) to 1.
- `cache_extent` — how far beyond the viewport, in pixels, content is built ahead of time.
- `scroll`, `auto_scroll`, `auto_scroll_animation` and `on_scroll` — scrolling behavior and events. `on_scroll` reports the position in `event.data` with the same keys as [`list_view`](/docs/control-list-view#scroll-events).
- `keyboard_dismiss_behavior` — `"on_drag"` hides the on-screen keyboard when the user drags the view.
- `expand`, `width`, `height` and the common layout properties.

For a collapsing header over one scrolling list or over tabs, use
[`nested_scroll_view`](/docs/control-nested-scroll-view).
