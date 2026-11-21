# Desktop Builds

Build native desktop clients:

```bash
ruflet build macos
ruflet build windows
ruflet build linux
```

Use `--self` for a self-contained application. A server-driven desktop build
you distribute needs `app.backend_url` in `ruflet.yaml`. Without it, the
client connects to the URL its launcher passes, as `ruflet run --desktop`
does, or to `http://localhost:8550`.

## Icons

Desktop builds generate the macOS and Windows icons from `assets.icon_launcher`
in `ruflet.yaml`. A `macos:` or `windows:` section, or `icon_macos` and
`icon_windows` under `assets`, give a platform its own image:

```yaml
assets:
  icon_launcher: assets/icon.png

windows:
  icon_launcher: assets/icon.ico
  icon_size: 256
```

A Windows icon may be a `.ico` file, and `icon_size` sets the generated
icon's size in pixels (48 by default). Linux builds generate no icon, and no
desktop build generates a splash screen: Ruflet ignores those keys with a
build note. See [Platform sections](/docs/configuration-reference#platform-sections).

## macOS signing and network access

`ruflet build macos` does not set the macOS project's signing team; choose it
in Xcode. It does write `ios.team_id` into the iOS project of the same client.
Set `macos.local_network: true` when the app reaches services on the local
network; see [Local network access](/docs/configuration-reference#local-network-access).

## Development client

```bash
ruflet run main.rb --desktop
ruflet update desktop
```

`ruflet run --desktop` uses the cached prebuilt desktop client. `ruflet build`
creates a distributable application from the managed Flutter workspace.

Packaging, signing, installers, and store submission remain platform-specific
release tasks.
