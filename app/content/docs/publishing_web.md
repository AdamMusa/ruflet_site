# Web

Ruflet can run and ship the same app as a web experience.

## Run locally

```bash
ruflet run main.rb --web
```

The CLI starts the backend, serves the web client locally, and opens the browser when possible.

## Build for the web

```bash
ruflet build web
```

## Why the web target matters

The web target is useful when you want:

- a shareable internal tool
- a browser-based admin surface
- one codebase for mobile, desktop, and browser experiences

## Related note

The same server-driven vs self-contained thinking still applies when you decide how your app should be delivered.
