# ListView

A scrollable list of controls, optimized for many items. Prefer it over a
scrolling `column` when the list is long.

## Example

```ruby
messages = [
  { subject: "Welcome to Ruflet", preview: "Here is how to build your first page." },
  { subject: "Your invoice", preview: "The November invoice is ready." },
  { subject: "Team update", preview: "Standup moves to 10:00 tomorrow." }
]

page.add(
  list_view(
    expand: true,
    spacing: 4,
    padding: 8,
    children: messages.map { |m| list_tile(title: text(m[:subject]), subtitle: text(m[:preview])) }
  )
)
```

## Common properties

- `children` — the list items
- `horizontal` — scroll horizontally instead of vertically
- `spacing`
- `padding`
- `item_extent` — fixed item size for faster layout
- `divider_thickness` — draw dividers between items
- `auto_scroll` — keep the latest item in view (chat/logs)
- `reverse`
- `cache_extent`

## Usage

`list_view` expands to fill its parent — give it `expand: true` inside a
`column`, or a fixed `height`. Items are built as they scroll into view
(`build_controls_on_demand`, on by default), so huge lists stay fast; set it
to `false` only for short lists that must all exist at once. Give each item a
`key` when items can move, so each keeps its own state.

## Scroll events

`on_scroll` fires as the list scrolls, at most once per `scroll_interval`
milliseconds (default 10). Read the position from `event.data`, a hash with Symbol keys:

- `:event_type` — `"start"`, `"update"`, `"end"`, `"user"` (the user changed direction) or `"overscroll"`
- `:pixels` — the scroll offset; `:min_scroll_extent` and `:max_scroll_extent` bound it, and `:viewport_dimension` is the visible length
- `:scroll_delta` on updates, `:direction` (`"idle"`, `"forward"` or `"reverse"`) on user events, and `:overscroll` and `:velocity` on overscroll

```ruby
position = text(value: "Top of the list")

page.add(
  column(
    expand: true,
    children: [
      position,
      list_view(
        (1..100).map { |n| list_tile(title: text("Row #{n}")) },
        expand: true,
        scroll_interval: 100,
        on_scroll: ->(event) {
          next unless event.data[:event_type] == "end"

          page.update(position, value: "Stopped at #{event.data[:pixels].round} of #{event.data[:max_scroll_extent].round} px")
        }
      )
    ]
  )
)
```

## Refreshing and loading more

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 these keywords raise ArgumentError (unknown keyword) and `scroll_to` does nothing.

Pull to refresh (`on_refresh`), `on_end_reached` for loading the next page,
`keyboard_dismiss_behavior`, `animate_changes` with `item_animation`, and
`scroll_to` are covered in [Controls and Layout](/docs/controls-and-layout#scrolling).

- `on_end_reached` — `event.data` has the keys `:pixels`, `:max_scroll_extent` and `:viewport_dimension`. It fires once per list length, so it can fire again after you add items.
- `item_animation` — `{ type:, duration:, curve: }`, where `type` is `"fade"`, `"size"`, `"fade_size"` (default) or `"slide"` and `duration` defaults to 250 milliseconds.
- `refresh_bgcolor` and `refresh_displacement` apply on Android, web, Windows and Linux only; `refresh_trigger_distance` on iOS and macOS only.
