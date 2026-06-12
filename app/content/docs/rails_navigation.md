# Navigation

Ruflet supports the Flet routing model: a page holds a **stack of views**
(`page.views`), navigation is driven by `page.go(route)` and `on_route_change`,
and the client back button sends `view_pop`.

`ruflet_rails` wraps that boilerplate in `Ruflet::Rails.routed`, so a
multi-screen app only describes how to build each route's view stack.

## The raw model

```ruby
page.views = [home_view, detail_view]   # a stack; the last view is visible
page.go("/store")                       # sets the route, fires on_route_change
# the client AppBar back arrow / system back sends view_pop -> pops the stack
```

## `Ruflet::Rails.routed`

`routed` wires `on_route_change`, `on_view_pop`, and the initial `go`. You
declare the stack for the current route; navigating rebuilds it.

```ruby
Ruflet.run do |page|
  Ruflet::Rails.routed(page) do |route, nav|
    nav.push(
      view(
        route: "/",
        appbar: app_bar(title: text("Store")),
        controls: [
          filled_button(content: text("Open product 7"),
                        on_click: ->(_e) { page.go("/products/7") })
        ]
      )
    )

    next unless route.start_with?("/products/")

    id = route.split("/").last
    nav.push(
      view(
        route: route,
        appbar: app_bar(title: text("Product #{id}")),
        controls: [text("Detail for product #{id}")]
      )
    )
  end
end
```

- `nav.push(view)` adds a screen to the stack for the current route.
- `page.go("/products/7")` pushes a screen; the back button pops it.
- A deep-linked initial route (`/products/7`) renders its full stack on connect.

## Map form

Declare a builder per route instead of one big block:

```ruby
Ruflet::Rails::RouteStack.new(page)
  .on("/")      { |nav| nav.push(home_view) }
  .on("/store") { |nav| nav.push(home_view); nav.push(store_view) }
  .start
```

## Single-screen vs. stack

A CRUD [resource component](/docs/rails-scaffolding) owns the whole screen (it
resets `page.views` on each render). Use `routed` when you want several screens
with native push/pop navigation between them.

## Two routing layers

Don't conflate them:

- **Rails `routes.rb` mount** (`at: "/store"`) — the HTTP base path where the
  whole Ruflet app lives.
- **In-app `page.route` / `page.go`** — client-side navigation *within* that
  mounted app. This is the stack `routed` manages.
