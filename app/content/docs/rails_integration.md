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
`config/initializers/ruflet.rb`, and an explicit `/ws` route. Add `--desktop`
(or `--client desktop`) to download the prebuilt desktop client at the same
time; `--client none` is the default.

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

The block receives the connected Ruflet page. `Dashboard` is an example of
your own application renderer; it is not a class supplied by `ruflet_rails`.

## Render Rails views

Choose one renderer for the Rails-powered section:

- [ERB to Native](/docs/rails-erb-to-native) turns Rails controller actions and
  their ERB templates into real native Ruflet widgets. Its [Widgets](/docs/rails-native-components)
  and [Services](/docs/rails-native-services) references document the complete
  ERB API.
- [Native Shell](/docs/rails-native-shell) keeps existing Rails pages as HTML
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

## Continue

- [Rails API Reference](/docs/rails-api-reference)
- [ERB to Native](/docs/rails-erb-to-native)
- [ERB-to-native Widgets](/docs/rails-native-components)
- [ERB-to-native Services](/docs/rails-native-services)
- [Choosing a Rails Mode](/docs/rails-native-html)
- [Native Shell](/docs/rails-native-shell)
- [Rails Assets and URLs](/docs/rails-assets)
