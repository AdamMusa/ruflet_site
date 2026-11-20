# Web Builds

Run the managed web client during development:

```bash
ruflet run main.rb --web
```

This starts the Ruby backend, serves the local web client, and opens a browser
when possible.

## Build

```bash
ruflet build web
```

A web build is always server-driven: the embedded Ruby runtime has no browser
implementation, so `--self` is not supported for web.

Set `app.backend_url` in `ruflet.yaml` when the web build is hosted apart from
its Ruby backend, for example on a static host or a CDN. The build bakes that
URL into the client. Without it, the client connects to the origin it was
loaded from. That works only when the Ruby backend, or a proxy that forwards
the WebSocket to it, serves the client from that same origin, as
`ruflet run --web` does.

## Icons and splash

The web icons, manifest colors and splash come from `assets` in
`ruflet.yaml`. A `web:` section overrides them for the web build:

```yaml
web:
  icon_launcher: assets/icon-web.png
  icon_background: "#0F172A"
  theme_color: "#0F172A"
  image_mode: contain
```

`icon_background` and `theme_color` color the web icons and the manifest.
`image_mode` sets how the splash image is drawn on the loading page:
`center`, `contain`, `stretch` or `cover`. `short_name` under `app` is the
manifest's short name. See
[Platform sections](/docs/configuration-reference#platform-sections).

## Deploy

Deploy the exported web build with the hosting and caching rules appropriate
for a Flutter web application. Ensure the Ruby backend is reachable from users'
browsers.
