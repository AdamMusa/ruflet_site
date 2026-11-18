# Choosing a Rails Mode

`ruflet_rails` offers three ways to build a Ruflet app on Rails. All three run
behind the one WebSocket route that the generator adds:

```ruby
# config/routes.rb
match "/ws",
  to: Ruflet::Rails.native(Rails.root.join("app/views/ruflet/main.rb")),
  via: :all
```

The entrypoint that route runs decides how screens are built.

## Ruby controls

Write the UI with Ruflet controls, as in any Ruflet app. Handlers can call your
models and services directly:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  page.add(text("Hello from Rails"))
end
```

## ERB as native controls

Keep screens in Rails ERB and render them as native controls, with no WebView:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.erb_to_native(page, start_url: "/native")
end
```

`/native` runs `NativeController#home` (or `#index`, then `#show`, when there
is no `home`) and renders its template. Each screen path names a controller
action by convention; see [ERB to Native](/docs/rails-erb-to-native).

## Rails HTML in a native shell

Keep an existing Rails website as HTML inside a managed native WebView shell:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.native_shell(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/dashboard",
    title: "Dashboard"
  )
end
```

The requested URL renders through normal Rails controllers, views, sessions,
CSS, and JavaScript. The native shell hosts that page in a WebView and can read
supported `data-ruflet-*` annotations for native chrome and platform actions.

## Choose between them

- Use Ruby controls when the UI is written in Ruflet's Ruby DSL.
- Use `erb_to_native` when Rails ERB should render native controls without a
  WebView.
- Use `native_shell` when an existing Rails website should remain HTML while
  gaining native app chrome and selected platform actions.

See [Rails API Reference](/docs/rails-api-reference) for exact signatures and
[Native Shell](/docs/rails-native-shell) for the managed shell.
