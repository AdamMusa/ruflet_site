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
ruflet build web --self
```

A server-driven web build requires `app.backend_url` in `ruflet.yaml`. A
self-contained web build packages the Ruby project with the client runtime.

Deploy the exported web build with the hosting and caching rules appropriate
for a Flutter web application. Ensure the configured backend URL is reachable
from users' browsers when using server-driven mode.
