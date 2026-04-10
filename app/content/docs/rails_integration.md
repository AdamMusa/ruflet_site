# Rails Integration

Ruflet already has a Rails-first integration package: `ruflet_rails`.

This is the right choice when you want Ruflet UI inside a Rails app instead of as a separate standalone project.

## Add the gem

```ruby
gem "ruflet_rails", ">= 0.0.5"
```

## Install into a Rails app

```bash
bin/rails generate ruflet:install
```

The generator creates and configures:

- `app/mobile/main.rb`
- `ruflet.yaml`
- Ruflet mount routes in `config/routes.rb`
- a client template when one is available locally

## Generated config

```yaml
app:
  name: My App
  ruflet_client_url: ""

services: []

assets:
  splash_screen: assets/splash.png
  icon_launcher: assets/icon.png
```

In Rails apps, asset paths are resolved from `app/assets/` during build.

## Build from Rails

The Rails integration exposes a build pipeline that mirrors the CLI:

```bash
bundle exec rake ruflet:build[web]
bundle exec rake ruflet:build[macos]
bundle exec rake ruflet:build[windows]
bundle exec rake ruflet:build[linux]
bundle exec rake ruflet:build[apk]
bundle exec rake ruflet:build[android]
bundle exec rake ruflet:build[ios]
bundle exec rake ruflet:build[aab]
```

## Minimal Rails-side app

```ruby
require "ruflet"

Ruflet.run do |page|
  page.title = "Hello"
  page.add(text("Hello Ruflet"))
end
```

## When to choose Rails integration

Use `ruflet_rails` when:

- your product already lives in Rails
- you want Ruflet screens backed by existing Rails data and routes
- you want to keep deployment and business logic centered in one Rails codebase

Use standalone Ruflet apps when:

- you want a clean app repo
- the UI/runtime lifecycle is independent from a Rails server
- you are packaging a more app-centric experience
