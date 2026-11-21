# SearchBar

A search field that opens a search view with suggestions. The bar's child
controls are the suggestions shown in the view; replace them as the query
changes.

## Example

```ruby
fruits = %w[Apple Apricot Banana Blueberry Cherry Grape Mango]
picked = text(value: "Nothing picked")
search = nil
matches = ->(query) {
  fruits.select { |name| name.downcase.include?(query.downcase) }.map do |name|
    list_tile(
      title: text(name),
      on_click: ->(_event) {
        search.close_view(name)
        page.update(picked, value: "Picked #{name}")
      }
    )
  end
}
search = search_bar(
  matches.call(""),
  bar_hint_text: "Search fruit",
  view_hint_text: "Type to filter",
  on_tap: ->(_event) { search.open_view },
  on_change: ->(event) { page.update(search, controls: matches.call(event.data.to_s)) }
)
page.add(column(children: [search, picked]))
```

## Common properties

- `controls` — the suggestions shown in the open view; the first positional argument sets them
- `value` — the current query
- `bar_hint_text` / `view_hint_text`
- `bar_leading` / `bar_trailing` / `view_leading` / `view_trailing`
- `full_screen` — open the view full screen
- `bar_bgcolor` / `view_bgcolor` / `divider_color`
- `capitalization` / `keyboard_type`
- `on_change` / `on_submit` — `event.data` is the query; with 0.0.23, a query such as `42` arrives parsed (see Usage)
- `on_tap` — the bar was tapped
- `on_tap_outside_view` — **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Tapping the bar does not open the view by itself: call `open_view` from
`on_tap`, as above. `close_view(text)` closes the view and puts `text` in the
bar; always pass the text you want to keep. `focus` moves keyboard focus to the
bar.

The client writes the query to `value` as the user types, so read it later
with `search.props["value"]`. With 0.0.23, Ruflet parses `on_change` and
`on_submit` data as JSON when it can, so a query of `42` arrives as the Integer
42 in `event.data` and in `props["value"]`; call `.to_s` when you need the
text. In the next release the query stays a String in both. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`event.control.value` and `search.value` return the same query; with 0.0.23
they raise NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS there is no separate search view: the bar lists its
suggestions under itself while it is focused and not empty.
`full_screen`, `divider_color`, `capitalization`, `keyboard_type` and the
`view_*` properties apply on Android, Windows and Linux only. So do
`shrink_wrap` and the bar's styling: `bar_border_side`, `bar_elevation`,
`bar_shape`, `bar_padding`, `bar_scroll_padding`, `bar_shadow_color`,
`bar_overlay_color`, `bar_size_constraints`, `bar_text_style` and
`bar_hint_text_style`. `bar_bgcolor`, `bar_hint_text`, `bar_leading` and
`bar_trailing` work everywhere. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

On iOS and macOS, `open_view` focuses the bar and lists the suggestions before
the user types, and `close_view(text)` puts `text` in the bar and hides them;
with 0.0.23 both do nothing there, so a picked suggestion leaves the typed query
in the bar. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
