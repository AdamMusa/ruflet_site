# SliverAppBar

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

An app bar that collapses, pins or floats as its scroll view scrolls. Use it
as a sliver of a [`custom_scroll_view`](/docs/control-custom-scroll-view) or as
a header sliver of a [`nested_scroll_view`](/docs/control-nested-scroll-view).
iOS clients draw a Cupertino navigation bar.

## Example

```ruby
articles = (1..20).map { |number| "Article #{number}" }

page.add(
  custom_scroll_view(
    [
      sliver_app_bar(
        title: text("Reading list"),
        variant: "large",
        actions: [icon_button(icon: "search", on_click: ->(_event) {})]
      ),
      sliver_list(articles.map { |title| list_tile(title: text(title)) })
    ],
    expand: true
  )
)
```

## Variants and scroll behavior

- `variant` — `"small"` (default), `"medium"` or `"large"`. Medium and large show a big title that shrinks into the bar as the view scrolls.
- `pinned` — keep the collapsed bar visible. Defaults to `true` for medium and large and `false` for small, which scrolls away.
- `floating` — show the bar again as soon as the user scrolls back up.
- `snap` — with `floating: true`, animate the bar fully in or out instead of following the finger.
- `stretch` — stretch the bar when the user overscrolls at the top.

## Properties

- `title`, `leading` and `actions` — the bar contents. `title` takes a String or a control.
- `bottom` and `bottom_height` — a control under the toolbar, such as a `tab_bar`, and its height (default 48).
- `flexible_space` — a control behind the expanded bar on Material, shown below the bar on iOS.
- `expanded_height`, `collapsed_height` and `toolbar_height` — bar heights on Material.
- `bgcolor`, `color`, `elevation`, `scrolled_under_elevation`, `shadow_color` and `center_title` — appearance.
- `automatically_imply_leading` — show a back button when the view can go back (default `true`).
- `previous_page_title`, `border`, `always_show_middle` and `transition_between_routes` — iOS navigation bar options.

`sliver_app_bar` only works inside a scroll view's slivers. For the bar of a
whole page, use [`app_bar`](/docs/control-app-bar).
