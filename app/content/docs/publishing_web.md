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

Deploy the exported web build with the hosting and caching rules appropriate
for a Flutter web application. Ensure the Ruby backend is reachable from users'
browsers.
