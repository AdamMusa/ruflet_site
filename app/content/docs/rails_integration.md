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

## Choose a delivery API

### Native and desktop endpoint

Use `Ruflet::Rails.app` to expose an app file to native and desktop clients:

```ruby
match "/ws",
  to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")),
  via: :all
```

`app(path)` is shorthand for `endpoint(app_file: path)`. `endpoint` accepts
exactly one source: an app file or a block.

```ruby
Ruflet::Rails.endpoint(app_file: Rails.root.join("app/views/ruflet/main.rb"))
Ruflet::Rails.endpoint { |page| Dashboard.render(page) }
```

### Mounted Ruflet web app

Mount `web_app` when Rails should serve the Flutter web frontend and its
WebSocket from one route:

```ruby
mount Ruflet::Rails.web_app(
  app_file: Rails.root.join("app/views/ruflet/main.rb")
), at: "/app"
```

Install the prebuilt web frontend with:

```bash
rake ruflet:web
```

### ERB rendered as native controls

Use `erb_to_native` when Rails routes, controllers, and ERB templates should
produce a real native control tree:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.erb_to_native(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/mobile",
    title: "My app"
  )
end
```

Links navigate the native view stack, forms submit through Rails, and service
actions invoke the device. Route dispatch is in-process; no WebView or second
HTTP connection is used. Start with [ERB to Native](/docs/rails-erb-to-native),
then use the complete [Components](/docs/rails-native-components) and
[Services](/docs/rails-native-services) references.

### Rails HTML in a native WebView shell

Use `native_app` when the body should remain normal Rails HTML in a WebView but
the surrounding app bar and navigation should be native:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.native_app(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/dashboard",
    title: "Dashboard"
  )
end
```

The shell reads annotations emitted by Ruflet's WebView helpers. The page body
remains HTML. Choose `erb_to_native` instead when the body itself should be
native controls.

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
- [ERB-to-native Components](/docs/rails-native-components)
- [ERB-to-native Services](/docs/rails-native-services)
- [Mounted Rails Web Apps](/docs/rails-native-html)
- [WebView Apps](/docs/rails-webview-apps)
- [Rails Assets and URLs](/docs/rails-assets)
