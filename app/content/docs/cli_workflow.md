# CLI Workflow

The Ruflet CLI is the center of the developer experience. It is responsible for project setup, client launch, build orchestration, device tooling, and local environment checks.

## Available commands

```bash
ruflet --version
ruflet new <appname>
ruflet run [scriptname|path] [--web|--desktop] [--port PORT]
ruflet build <apk|android|ios|aab|web|macos|windows|linux> [--self] [--verbose]
ruflet install [--device DEVICE_ID] [--verbose]
ruflet update [web|desktop|all] [--check] [--force] [--platform PLATFORM]
ruflet debug [scriptname|path]
ruflet devices
ruflet emulators
ruflet doctor
```

## `ruflet new`

Use this to scaffold a fresh project:

```bash
ruflet new my_app
```

What it writes:

- `main.rb` with a starter counter app
- `Gemfile`
- `README.md`
- `ruflet.yaml`

What `ruflet.yaml` controls:

- app metadata
- package name and organization
- backend URL for server-driven builds
- enabled client services/extensions
- splash and icon assets
- build theming values

## `ruflet run`

This is the fastest way to develop a Ruflet app:

```bash
ruflet run main.rb
ruflet run main.rb --web
ruflet run main.rb --desktop
ruflet run main.rb --port 9000
```

Important behavior:

- Mobile is the default target.
- Ruflet resolves `main` and `main.rb` automatically.
- If a `Gemfile` is present, Ruflet checks `bundle` first and installs missing gems when needed.
- The CLI prints connection details for the selected target.
- Web launch spins up a local static host for the web client and opens the browser.
- Desktop launch waits for the backend, then opens a desktop client when available.

## `ruflet build`

Use builds when you are ready to package the app:

```bash
ruflet build apk
ruflet build ios
ruflet build web
ruflet build macos
ruflet build windows
ruflet build linux
```

There are two build modes:

- Default mode is **server-driven**. It expects `backend_url` to be configured in `ruflet.yaml`.
- `--self` is **self-contained**. It uses the embedded runtime/client entrypoint.

```bash
ruflet build android --self
ruflet build ios --self
```

## `ruflet install`

Install a previously built app to a device:

```bash
ruflet install
ruflet install --device emulator-5554
```

This command syncs exported build outputs back into the Flutter client workspace and asks Flutter to install the app.

## `ruflet update`

Update cached prebuilt clients:

```bash
ruflet update all
ruflet update web --check
ruflet update desktop --platform macos
```

Use `--check` when you only want to inspect the local cache and release tag state.

## `ruflet debug`

Run the underlying Flutter client directly when you need lower-level debugging:

```bash
ruflet debug web
ruflet debug ios
ruflet debug --device-id chrome
```

This is especially useful when you are working on client behavior instead of the Ruby app layer.

## `ruflet doctor`, `devices`, and `emulators`

Use these commands to inspect your local toolchain:

- `ruflet doctor` checks Ruby, Flutter host target, and template availability.
- `ruflet doctor --fix` can fetch missing template/tooling dependencies.
- `ruflet devices` shows Flutter-visible devices.
- `ruflet emulators` lists available emulators and can launch one with `--start`.

## Recommended loop

1. `ruflet new my_app`
2. `cd my_app`
3. `bundle install`
4. `ruflet run main.rb`
5. Iterate on controls and page updates
6. `ruflet build ...` when you are ready to package
