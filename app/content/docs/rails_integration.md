# Rails Integration

`ruflet_rails` lets a Rails process serve Ruflet mobile, desktop, and web
clients. Ruflet entrypoints can use Rails models and application services.
Rails views can render directly into native controls with ERB to Native or
remain HTML inside a managed native WebView shell.

## Install

```ruby
# Gemfile
gem "ruflet_rails"
```

```bash
bundle install
bin/rails generate ruflet:install
```

The generator creates `app/views/ruflet/main.rb`,
`config/initializers/ruflet.rb`, and an explicit `/ws` route. Add `--web`,
`--desktop`, or `--client web|desktop|all|none` to install a prebuilt client at
the same time.

## Hybrid Ruflet and Rails

A Ruflet app built with `--self` can keep its shell, navigation, offline
screens, and small local workflows inside the app. When a feature needs Rails,
Active Record, background jobs, or a CRuby gem that the embedded runtime does
not support, display that feature from a server-driven Rails endpoint with
`ruflet_app`.

```ruby
RAILS_URL = "https://app.example.com"

Ruflet.run do |page|
  page.add(
    column(
      expand: true,
      controls: [
        text("This header runs in the local Ruflet app"),
        ruflet_app(
          url: RAILS_URL,
          expand: true,
          app_startup_screen_message: "Connecting to Rails…",
          reconnect_timeout_ms: 10_000
        )
      ]
    )
  )
end
```

Pass the reachable HTTP or HTTPS base URL, not `/ws`. The Rails app exposes its
Ruflet endpoint at `/ws`, and the client manages that connection. Local screens
remain part of the self-contained app; the Rails section requires network
access to the server.

This split keeps server-only code and gems out of the installed app while the
Rails side uses the normal server-side Ruby ecosystem. The complete example lives in
`RufletApp/demo/hybride.rb` and connects to `ruflet_rails_demo`.

## Connect clients to Rails

### Native and desktop endpoint

Use `Ruflet::Rails.native` to expose an app file to native and desktop clients:

```ruby
match "/ws",
  to: Ruflet::Rails.native(Rails.root.join("app/views/ruflet/main.rb")),
  via: :all
```

Pass either an app file or a block:

```ruby
Ruflet::Rails.native(Rails.root.join("app/views/ruflet/main.rb"))
Ruflet::Rails.native { |page| Dashboard.render(page) }
```

### Mounted Ruflet web app

Mount `web` when Rails should serve the Flutter web frontend and its
WebSocket from one route:

```ruby
mount Ruflet::Rails.web(
  app_file: Rails.root.join("app/views/ruflet/main.rb")
), at: "/app"
```

Install the prebuilt web frontend with:

```bash
rake ruflet:web
```

## Render Rails views

Choose one renderer for the Rails-powered section:

- [ERB to Native](/docs/rails-erb-to-native) turns Rails routes and templates
  into real native Ruflet widgets. Its [Widgets](/docs/rails-native-components)
  and [Services](/docs/rails-native-services) references document the complete
  ERB API.
- [WebView Apps](/docs/rails-webview-apps) keeps existing Rails pages as HTML
  inside a managed native shell.

## Configuration and builds

`config/initializers/ruflet.rb` holds the backend URL, app name, services,
extensions, assets, and build colors. Use `Ruflet::Rails.backend_url` rather
than hard-coding `localhost`, because a real device must reach the Rails
server.

```bash
rake ruflet:build[apk]
rake ruflet:build[aab]
rake ruflet:build[ios]
rake ruflet:build[macos]
rake ruflet:build[windows]
rake ruflet:build[linux]
rake ruflet:install[DEVICE_ID]
```

The web client is installed with `rake ruflet:web`; it is not a target of the
Rails build task.

## Continue

- [Rails API Reference](/docs/rails-api-reference)
- [ERB to Native](/docs/rails-erb-to-native)
- [ERB-to-native Widgets](/docs/rails-native-components)
- [ERB-to-native Services](/docs/rails-native-services)
- [Mounted Rails Web Apps](/docs/rails-native-html)
- [WebView Apps](/docs/rails-webview-apps)
- [Rails Assets and URLs](/docs/rails-assets)
