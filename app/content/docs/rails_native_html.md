# Native HTML Apps

Build a fully native app by writing HTML in your Rails views. With
`Ruflet::Rails.html_to_native`, every page you render is compiled into **real native
controls** — there is no WebView. State lives in Rails, each interaction is a
request, and the response markup re-renders the screen.

This is the fastest way to ship a native app from an existing Rails codebase:
you keep controllers, views, sessions, redirects, and CSRF, and write screens
with tags like `<column>`, `<row>`, `<text>`, and `<button>` instead of HTML
that targets a browser.

## How it compares

Ruflet gives you three ways to bring Rails into a native client:

1. `Ruflet::Rails.html_to_native` renders your Rails HTML as native controls. No
   WebView — the markup *becomes* the widgets.
2. `Ruflet::Rails.native_shell` keeps your web pages in a native WebView and adds
   a native shell (app bar, drawer, navigation) around them. See
   [Webview Apps](/docs/rails-webview-apps).
3. `Ruflet::Rails.native` serves a Ruby-driven Ruflet UI over the WebSocket
   protocol. See [Rails Integration](/docs/rails-integration).

Reach for `html_to_native` when you want a genuinely native UI but would rather write
markup in Rails views than build the control tree in Ruby.

## Quick start

Point the native entrypoint at an `html_to_native` app:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.html_to_native(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/app",
    title: "My App"
  )
end
```

Use `Ruflet::Rails.backend_url` instead of hard-coding `localhost`, so the app
reaches your server from a real device.

Screens are ordinary Rails views. A controller renders markup; the client shows
native controls:

```ruby
# app/controllers/app_controller.rb
class AppController < ApplicationController
  layout "native"

  def show
    @count = session[:count] ||= 0
  end

  def increment
    session[:count] = (session[:count] || 0) + 1
    redirect_to app_path
  end
end
```

```erb
<%# app/views/app/show.html.erb %>
<appbar title="Counter"></appbar>

<column class="p-6 gap-8 items-center justify-center flex-1">
  <text class="text-5xl font-bold"><%= @count %></text>
  <row class="gap-3">
    <button variant="filled" icon="add" on-click="<%= increment_path %>">Add</button>
  </row>
</column>
```

A minimal layout is enough — the CSRF token lets native actions and forms post
back to Rails:

```erb
<%# app/views/layouts/native.html.erb %>
<%= csrf_meta_tags %>
<%= yield %>
```

## How it works

- The client requests `start_url`. Ruflet compiles the response into native
  controls and shows them as a screen.
- A `<a href>` link pushes a new native screen (fetched from that URL). The
  native back button and gesture pop it.
- An `on-click` action posts to Rails and re-renders the current screen in
  place with the response. Rails `redirect_to` is followed, so redirect-based
  flows work unchanged.
- Requests carry the Rails session cookie and CSRF token, plus an
  `X-Ruflet-Native: 1` header, so one controller action can serve both a
  browser page and a native screen.

## Layout and content

- **Layout** — `<column>`, `<row>`, `<stack>`, `<div>`/`<section>` (a
  container), `<card>`, `<center>`, `<spacer>`, `<list>`, `<grid>`.
- **Content** — `<text>`, `<h1>`–`<h6>`, `<p>`, `<markdown>`, `<img>`,
  `<icon>`, `<hr>`, `<ul>`/`<li>`.

```erb
<column class="p-6 gap-4">
  <h1>Inbox</h1>
  <card class="p-4">
    <row class="gap-3 items-center">
      <icon name="mail" class="text-emerald-600"></icon>
      <column class="gap-1 flex-1">
        <text class="font-semibold">Welcome</text>
        <text class="text-sm text-slate-500">Tap to read</text>
      </column>
    </row>
  </card>
</column>
```

Screens can also be written with Ruby helpers (auto-included into ActionView),
and both styles mix freely in one template. Snake-case keys become the matching
attributes (`on_click:` → `on-click`):

```erb
<%= column class: "p-6 gap-6 items-center justify-center flex-1" do %>
  <%= text @count, class: "text-5xl font-bold" %>
  <%= button "Add", variant: "filled", icon: "add", on_click: increment_path %>
  <%= link "Settings", settings_path %>
<% end %>
```

## Guides

The rest of the framework is covered in focused guides:

- [Styling](/docs/rails-native-styling) — the full class vocabulary: spacing,
  color, typography, borders, transforms, and transitions.
- [Components](/docs/rails-native-components) — layout and content tags, the
  first-class components (badge, chip, tabs, list tile, table…), and the full
  control catalog.
- [Navigation and Forms](/docs/rails-native-interactivity) — links and
  navigation modes, `on-click` actions, forms, and app chrome (app bar, bottom
  navigation, FAB).
- [Services and Extensions](/docs/rails-native-services) — the camera, GPS,
  sensors, storage, and visible extensions like video, maps, and charts.

## Errors

A single bad element never takes down a screen — it renders a small inline
placeholder and the rest of the page keeps building. HTTP errors (except `422`,
which is a form re-render) show a compact error screen with the status and URL,
so a wrong route or a server exception is visible instead of a blank screen.

## Related guides

- [Rails Integration](/docs/rails-integration)
- [Webview Apps](/docs/rails-webview-apps)
- [Navigation](/docs/rails-navigation)
- [Controls](/docs/component-reference)
