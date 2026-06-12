# Assets and URLs

Server-driven UI renders on a separate device — a simulator, a phone, a
browser. A bare `/assets/logo.png` path can't load there, so image sources and
the client connection need **absolute URLs**. `ruflet_rails` resolves them for
you.

## `backend_url` — always required

`backend_url` is the base URL the Flutter client uses to reach your Rails app.
It backs asset URLs, the build-time `RUFLET_URL` define, and the desktop
launcher, so a Rails Ruflet app always sets it:

```ruby
Ruflet::Rails.configure do |config|
  config.backend_url = ENV.fetch("RUFLET_BACKEND_URL") do
    Rails.env.production? ? "https://example.com" : "http://localhost:3000"
  end
end
```

`Ruflet::Rails.backend_url` resolves, in order:

1. an explicit `host:` argument
2. `config.backend_url`
3. the host the client connected on (the live WebSocket request)

A build has no live request, so set `config.backend_url` to cover that case.

> Tip: `localhost` only works in the simulator. To test on a physical device,
> set `RUFLET_BACKEND_URL=http://<your-LAN-IP>:3000`.

## `asset_url` — display Rails assets as images

```ruby
image(src: Ruflet::Rails.asset_url("logo.png"), fit: "cover")
image(src: Ruflet::Rails.image_url("brand/header.png"))   # alias
```

- The **path** comes from the Rails asset pipeline — digested in production
  (`/assets/logo-<digest>.png`), plain otherwise.
- The **host** comes from `backend_url` (above), so the URL is absolute and
  reachable from the device.
- An `asset_host`/CDN that already returns an absolute URL, or a value that is
  already a full URL, passes through unchanged.

```ruby
Ruflet::Rails.asset_url("logo.png")
# => "http://localhost:3000/logo.png"   (or /assets/logo-<digest>.png with a pipeline)
```

## `ruflet_frame` — embed native UI in an ERB page

A Ruflet web frontend is a Flutter app mounted at a route. To drop that native
UI into a server-rendered Rails page, render it in an isolated frame:

```erb
<%= ruflet_frame "/products", height: 640 %>
<%= ruflet_frame "/showcase", height: "80vh", width: "100%" %>
```

- Same-origin by default (a relative path), so the Ruflet WebSocket and assets
  resolve against this host with no extra config. Pass a full URL for a
  cross-host embed.
- Numeric dimensions become pixels; string dimensions pass through.
- Extra attributes pass through (`data_role:` → `data-role`), and all values
  are HTML-escaped.

The helper is auto-included into ActionView, so it works in any `.erb` template.
