# NestedScrollView

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A collapsing header over a scrolling body. The header slivers, usually a
[`sliver_app_bar`](/docs/control-sliver-app-bar), collapse or pin as the user
scrolls the `body`.

## Example

```ruby
messages = (1..30).map { |number| "Message #{number}" }

page.add(
  nested_scroll_view(
    [sliver_app_bar(title: text("Inbox"), variant: "large")],
    expand: true,
    body: list_view(
      children: messages.map { |subject| list_tile(title: text(subject)) }
    )
  )
)
```

Give the header slivers as the first argument, as `header_slivers:`, or in a
block. `body:` is required: `nested_scroll_view` raises ArgumentError when it
is missing or is not a control.

## Tabs under a collapsing header

Put the tab bar in the app bar's `bottom` and a `tab_bar_view` in `body`. Each
tab page scrolls under the pinned header:

```ruby
inbox = %w[Invoice Receipt Welcome]
sent = %w[Re:Invoice Re:Welcome]

page.add(
  tabs(
    length: 2,
    expand: true,
    content: nested_scroll_view(
      [
        sliver_app_bar(
          title: text("Mail"),
          pinned: true,
          bottom: tab_bar([tab(label: "Inbox"), tab(label: "Sent")])
        )
      ],
      body: tab_bar_view([
        list_view(children: inbox.map { |subject| list_tile(title: text(subject)) }),
        list_view(children: sent.map { |subject| list_tile(title: text(subject)) })
      ])
    )
  )
)
```

## Properties

- `header_slivers` — the slivers above the body, usually one `sliver_app_bar`.
- `body` — one control (required).
- `float_header_slivers` — when the user scrolls back, bring a `floating` header back before the body scrolls (default `false`).
- `horizontal` and `reverse` — scroll direction (both default `false`).
- `scroll`, `auto_scroll` and `on_scroll` — act on the outer scroll, which moves the header.
- `clip_behavior` and the common layout properties.

## Usage

Make the scrolling list the `body` itself, or each page of a `tab_bar_view`
body: a `list_view`, `grid_view`, `custom_scroll_view`, or a `column` or `row`
with `scroll:`. Those lists drive the header: it collapses before they scroll.
Any other body is placed below the pinned header, and a list nested deeper
inside it scrolls on its own without collapsing the header.

`scroll_to` acts on the outer scroll as well: `scroll_to(offset: 0)` expands
the header and returns the body lists to their top, and
`scroll_to(offset: -1)` collapses it.
