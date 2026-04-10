# Build and Release

Ruflet already supports packaging for the major targets you would expect from a Flutter-backed app stack.

## Build targets

Current CLI targets include:

- `apk`
- `android`
- `ios`
- `aab`
- `web`
- `macos`
- `windows`
- `linux`

Example commands:

```bash
ruflet build apk
ruflet build ios
ruflet build web
ruflet build macos
```

## Two build modes

### Server-driven mode

This is the default. Your packaged app expects a backend URL:

```yaml
app:
  backend_url: "https://api.example.com"
```

Use this mode when:

- the app should talk to a hosted Ruflet backend
- you want a thinner client package
- your release model already includes a deployed server

### Self-contained mode

Use `--self` to build against the embedded runtime/client entrypoint:

```bash
ruflet build android --self
ruflet build ios --self
```

Use this mode when:

- you want more standalone packaging
- the app logic should travel with the client build
- you are closer to an installed-app workflow than a hosted runtime

## Assets and branding

`ruflet.yaml` also drives build-time assets:

```yaml
assets:
  dir: assets
  splash_screen: assets/splash.png
  icon_launcher: assets/icon.png

build:
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  icon_background: "#FFFFFF"
  theme_color: "#FFFFFF"
```

## Installing builds

After building, use:

```bash
ruflet install
```

This helps move exported outputs into the client workspace and asks Flutter to install the app on a chosen device.

## Prebuilt client updates

Ruflet also has a client update flow:

```bash
ruflet update all
ruflet update web --check
```

This is useful when you rely on cached prebuilt clients for development.

## Shipping advice

- Decide early whether your app is server-driven or self-contained.
- If you need media, camera, storage, or other extensions, declare them up front in `ruflet.yaml`.
- Test the real build target early, especially on iOS and Android, because native permissions and packaging details matter.
