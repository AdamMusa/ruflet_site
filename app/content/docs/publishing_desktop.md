# Desktop Builds

Build native desktop clients:

```bash
ruflet build macos
ruflet build windows
ruflet build linux
```

Use `--self` for a self-contained application. Server-driven builds require
`app.backend_url` in `ruflet.yaml`.

## Development client

```bash
ruflet run main.rb --desktop
ruflet update desktop
```

`ruflet run --desktop` uses the cached prebuilt desktop client. `ruflet build`
creates a distributable application from the managed Flutter workspace.

Packaging, signing, installers, and store submission remain platform-specific
release tasks.
