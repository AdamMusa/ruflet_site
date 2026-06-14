# Rails Assets and URLs

A native Ruflet client runs on a different process or device from Rails.
Asset URLs used by that client must therefore be reachable from the client.

## Backend URL

Configure the deployed or device-reachable Rails URL in `ruflet.yaml`:

```yaml
app:
  name: My Rails App
  backend_url: https://app.example.com
```

`Ruflet::Rails.backend_url` resolves an explicit `host:` first, then the
configured backend URL, then the host of the active Ruflet request.

For development on a physical device, use the computer's LAN address instead
of `localhost`:

```yaml
app:
  backend_url: http://192.168.1.20:3000
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

## Embed a mounted Ruflet web app

Use `ruflet_frame` inside an ERB view to embed a mounted Ruflet web frontend:

```erb
<%= ruflet_frame "/dashboard", height: 640 %>
<%= ruflet_frame "/showcase", height: "80vh", width: "100%" %>
```

Relative paths stay same-origin. Numeric dimensions become pixels, string
dimensions pass through, and additional HTML attributes are escaped.

The helper is included in Action View automatically.
