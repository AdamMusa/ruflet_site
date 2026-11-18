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
- `on_change` / `on_submit` — `event.data` is the query
- `on_tap` — the bar was tapped
- `on_tap_outside_view` — **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Tapping the bar does not open the view by itself: call `open_view` from
`on_tap`, as above. `close_view(text)` closes the view and puts `text` in the
bar; always pass the text you want to keep. `focus` moves keyboard focus to the
bar.
