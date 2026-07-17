# Native HTML Components

Native HTML screens are built from tags that compile to real native controls.
This page lists the tags available beyond the [layout and content
basics](/docs/rails-native-html), and shows how to reach the rest of the Ruflet
control catalog.

Every tag has a matching Ruby helper, so you can write markup or helpers and mix
both in one template.

## Layout

- `<column>`, `<row>`, `<stack>` — the flex primitives
- `<container>` / `<div>` / `<section>` — a styled box
- `<card>` — an elevated surface
- `<center>` — center its child
- `<spacer>` — flexible empty space
- `<list>` — a scrolling list
- `<grid>` — a grid

## Content

- `<text>`, `<h1>`–`<h6>`, `<p>`
- `<markdown>` — rendered Markdown
- `<img>` / `<image>`
- `<icon name="…">`
- `<hr>` / `<divider>`
- `<ul>` / `<li>`

## First-class components

Some Ruflet features are not plain controls — a badge and a tooltip are
*properties* on the control they wrap, tabs are a controller with panes, and so
on. These tags handle that shape for you:

- `<badge label="3">…</badge>` — wraps a child and attaches a badge
- `<tooltip message="…">…</tooltip>` — wraps a child with a tooltip
- `<chip label="Ruby" icon="star">` — a compact chip
- `<avatar src="…">` or `<avatar>AM</avatar>` — image or initials
- `<list-tile title subtitle leading href>` — a tappable row
- `<expansion-tile title>…</expansion-tile>` — a collapsible section
- `<switch>`, `<checkbox>`, `<slider>`, `<radio>` — inputs (add a `name` to make
  them form fields)
- `<radio-group name value>…</radio-group>`
- `<segmented-button name value>…<segment>…</segmented-button>`
- `<tabs><tab label icon>…</tab></tabs>` — a native tab bar with panes
- `<table>` — a plain HTML table becomes a native data table

```erb
<tabs>
  <tab label="Overview"><text>Summary…</text></tab>
  <tab label="Details" icon="info"><text>More…</text></tab>
</tabs>

<list-tile title="Inbox" subtitle="12 unread" leading="mail" href="<%= inbox_path %>"></list-tile>

<badge label="3"><icon name="notifications"></icon></badge>
```

## The full control catalog

Any tag without a dedicated builder maps straight onto the Ruflet control
registry, with its attributes as props. That means the entire catalog — charts,
canvas, Cupertino controls, and more — works from markup. Text and child
elements are routed into whichever prop a control accepts (`content`,
`controls`, `label`, `title`), so controls build correctly whether they take a
label, a single child, or a list.

```erb
<progress-bar value="0.4"></progress-bar>
<cupertino-activity-indicator animating="true"></cupertino-activity-indicator>

<%# helper form: kebab tag from a snake name %>
<%= widget "bar-chart", interactive: true do %>
  <%= widget "bar-chart-group", x: 0 do %>
    <%= widget "bar-chart-rod", from_y: 0, to_y: 10 %>
  <% end %>
<% end %>
```

If a control needs an attribute it did not get (an icon name, a segment value),
that one element renders a small inline placeholder instead of taking down the
screen — so a typo is easy to spot.

## Ruby helpers

The same components are available as helpers. Snake-case keys become the
matching attributes (`on_click:` → `on-click`); Hash and Array values serialize
as JSON:

```erb
<%= card class: "p-4" do %>
  <%= row class: "gap-3 items-center" do %>
    <%= avatar "AM", class: "bg-violet-500" %>
    <%= column class: "gap-1 flex-1" do %>
      <%= text "Ada Lovelace", class: "font-semibold" %>
      <%= text "Online", class: "text-sm text-emerald-600" %>
    <% end %>
    <%= badge "3" do %><%= icon "chat" %><% end %>
  <% end %>
<% end %>
```

Helpers exist for the layout tags, content (`text`, `h1`–`h6`, `markdown`,
`image`, `icon`), `button` / `link`, chrome (`appbar`, `fab`, `bottom_nav`),
forms (`form`, `input`, `dropdown`, `submit`), the components above, and
`widget("bar-chart", …)` for anything else.

## Related guides

- [Native HTML Apps](/docs/rails-native-html)
- [Styling](/docs/rails-native-styling)
- [Navigation and Forms](/docs/rails-native-interactivity)
- [Services and Extensions](/docs/rails-native-services)
