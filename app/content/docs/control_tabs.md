# Tabs

Switch between related sections inside one screen. A `tabs` control holds the
selection and coordinates a [`tab_bar`](/docs/control-tab-bar) of
[`tab`](/docs/control-tab)s with a [`tab_bar_view`](/docs/control-tab-bar-view)
of pages, one page per tab.

## Example

```ruby
status = text(value: "Selected tab: 0")
page.add(
  tabs(
    length: 2,
    selected_index: 0,
    expand: true,
    content: column(
      expand: true,
      children: [
        tab_bar([
          tab("Home", icon: "home"),
          tab("Settings", icon: "settings")
        ]),
        tab_bar_view([text("Home content"), text("Settings content")], expand: true),
        status
      ]
    ),
    on_change: ->(event) { page.update(status, value: "Selected tab: #{event.data}") }
  )
)
```

## Properties

- `length` — the number of tabs (required); it must equal the number of `tab`s and of pages
- `content` — the layout that holds the `tab_bar` and the `tab_bar_view`; the first positional argument sets it
- `selected_index` — the selected tab, starting at 0; change it with `page.update` to move to another tab
- `animation_duration` — length of the move between tabs, in milliseconds (default 100; Android, web, Windows and Linux only)
- `expand`, `width` and `height` — layout sizing

## Events

- `on_change` — the selected tab changed, from a tap, a swipe or `move_to`. `event.data` is the new index.

## Methods

- `move_to(index, duration: nil, curve: nil)` — select a tab from code; a negative index counts from the end. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Give the `tab_bar_view` a height or `expand: true`, as above: it shows an
error when its height is unbounded. With 0.0.23, move to another tab by
updating `selected_index`:

```ruby
pages = tabs(length: 2, content: column(expand: true, children: [tab_bar([tab("One"), tab("Two")]), tab_bar_view([text("1"), text("2")], expand: true)]), expand: true)
page.add(column(expand: true, children: [button("Go to Two", on_click: ->(_event) { page.update(pages, selected_index: 1) }), pages]))
```

On Android, web, Windows and Linux the tab bar is a Material tab bar with an
indicator line, and the user can swipe between pages. On iOS and macOS it is a
sliding segmented control, the pages do not swipe, and the tab bar's styling
keywords other than `indicator_color` do not apply.
