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
implementation, so `--self` is not supported for web. The client learns its
server from the origin it is served from, so `app.backend_url` in `ruflet.yaml`
may be omitted; when it is set, the build uses that URL instead.

Deploy the exported web build with the hosting and caching rules appropriate
for a Flutter web application. Ensure the Ruby backend is reachable from users'
browsers.
