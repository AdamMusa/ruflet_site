# Rails Assets and URLs

A native Ruflet client runs on a different process or device from Rails.
Asset URLs used by that client must therefore be reachable from the client.

## Backend URL

Configure the deployed or device-reachable Rails URL in
`config/initializers/ruflet.rb`:

```ruby
Ruflet::Rails.configure do |config|
  config.backend_url = "https://app.example.com"
end
```

`Ruflet::Rails.backend_url` resolves an explicit `host:` first, then
`config.backend_url`, then the host of the active Ruflet request. A Rails app
does not need `ruflet.yaml` for this. Two tools fall back to it: the desktop
launcher when no `config.backend_url` is set, and `rake ruflet:build` when the
initializer sets none of the values it passes to the build (backend URL, app
name, services, extensions, or icon, splash, and theme settings).

For development on a physical device, use the computer's LAN address instead
of `localhost`. The generated initializer reads `RUFLET_BACKEND_URL`, so you can
set it per run:

```bash
RUFLET_BACKEND_URL=http://192.168.1.20:3000 bin/rails server -b 0.0.0.0
```

## Rails asset URLs

Use `asset_url` to resolve an asset-pipeline path and make it absolute:

```ruby
image(src: Ruflet::Rails.asset_url("logo.png"), fit: "cover")
image(src: Ruflet::Rails.image_url("brand/header.png"))
```

`image_url` is an alias for `asset_url`.

```ruby
Ruflet::Rails.asset_url("logo.png", host: "https://app.example.com")
```

An existing absolute URL or asset-host URL passes through unchanged.
