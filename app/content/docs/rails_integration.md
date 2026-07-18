# Rails Integration

`ruflet_rails` lets a Rails application serve native, desktop, and web clients
from one codebase. Your Ruflet screens run inside Rails and can use models,
services, sessions, and application logic directly.

## Install

Add the gem and run the generator:

```ruby
gem "ruflet_rails"
```

```bash
bundle install
bin/rails generate ruflet:install
```

The generator creates `app/views/ruflet/main.rb` (the client entrypoint),
`config/initializers/ruflet.rb`, and a `/ws` route that native, desktop, and
web clients connect to:

```ruby
match "/ws",
  to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")),
  via: :all
```

`Ruflet::Rails.app(path)` is shorthand for
`Ruflet::Rails.endpoint(app_file: path)`. An endpoint takes exactly one source —
an app file or a block:

```ruby
Ruflet::Rails.endpoint(app_file: Rails.root.join("app/views/ruflet/main.rb"))
Ruflet::Rails.endpoint { |page| Dashboard.render(page) }
```

## Three ways to build the UI

`main.rb` chooses how your app's UI is produced. Pick the one that fits — you
can change your mind by editing this one file.

### 1. Ruby-driven UI — `Ruflet::Rails.native`

Build the native control tree in Ruby. Widget helpers are available directly:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  page.title = "Account"
  page.add(
    safe_area(
      container(
        padding: 24,
        content: column(
          spacing: 12,
          children: [
            text("Account", size: 28, weight: "bold"),
            text("Signed in as #{Current.user.email}")
          ]
        )
      )
    )
  )
end
```

To serve this UI to a **web** client, install the prebuilt web client and mount
it at a route — `native` serves the client and its WebSocket together:

```bash
rake ruflet:web
```

```ruby
Rails.application.routes.draw do
  mount Ruflet::Rails.native(app_file: Rails.root.join("app/views/ruflet/main.rb")), at: "/app"
end
```

### 2. HTML rendered as native controls — `Ruflet::Rails.erb_to_native`

Write screens as HTML in ordinary Rails views; Ruflet compiles each page into
real native controls, with no WebView. State lives in Rails and every
interaction is a request.

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.erb_to_native(page, start_url: "#{Ruflet::Rails.backend_url}/app")
end
```

```erb
<%# app/views/app/show.html.erb %>
<appbar title="Counter"></appbar>
<column class="p-6 gap-6 items-center justify-center flex-1">
  <text class="text-5xl font-bold"><%= @count %></text>
  <button variant="filled" icon="add" on-click="<%= increment_path %>">Add</button>
</column>
```

See [Native HTML Apps](/docs/rails-native-html) for the full guide.

### 3. Web pages in a native shell — `Ruflet::Rails.native_shell`

Keep your existing web pages in a native WebView while Ruflet owns the native
chrome — app bar, drawer, navigation, sheets, and dialogs — declared from ERB.

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.native_shell(page, start_url: Ruflet::Rails.backend_url, title: "My App")
end
```

See [Webview Apps](/docs/rails-webview-apps) for the full guide.

## Configuration

`config/initializers/ruflet.rb` is the source of truth for the app name,
backend URL, services, splash/icon assets, and build colors. Use
`Ruflet::Rails.backend_url` in code instead of hard-coding `localhost`, so the
app reaches your server from a real device.

## Build native clients

`ruflet_rails` builds native clients through Rails tasks:

```bash
rake ruflet:build[desktop]
rake ruflet:build[macos]
rake ruflet:build[apk]
rake ruflet:build[ios]
rake ruflet:build[aab]
```

The web client is installed with `rake ruflet:web`; it is not compiled through
`ruflet:build`.

## Related guides

- [Native HTML Apps](/docs/rails-native-html) — write screens as HTML
- [Webview Apps](/docs/rails-webview-apps) — wrap web pages in a native shell
- [Assets and URLs](/docs/rails-assets)
