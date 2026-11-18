# CLI Reference

This reference describes the Ruflet command-line interface. Run Ruflet
commands directly with the installed `ruflet` executable.

```text
ruflet <command> [arguments] [options]
```

Use `ruflet help` or `ruflet --help` for the command summary. Use
`ruflet --version`, `ruflet -v`, or `ruflet version` to print the installed
version.

## Create a project

```text
ruflet new <appname>
ruflet create <appname>
ruflet bootstrap <appname>
ruflet init <appname>
```

`new`, `create`, `bootstrap`, and `init` create the same starter project. The
generated project includes `main.rb`, `Gemfile`, `ruflet.yaml`,
`services.yaml`, and starter assets.

## Run

```text
ruflet run [script|path] [--web|--desktop] [--port PORT] [--no-reload]
```

- The script defaults to `main.rb`; `main`, `main.rb`, and a path to another
  Ruby file are accepted.
- Mobile development is the default target. `--web` opens the managed web
  client and `--desktop` starts the managed desktop client.
- The server listens on port `8550` by default. `--port PORT` overrides it;
  `RUFLET_PORT` provides the runtime default.
- Hot reload is enabled by default and watches Ruby files. Press `r` in the
  running terminal to rerun the app against the live page. Press `R` to restart
  the Ruby backend. Use `--no-reload` to disable the watcher.
- When the project has a `Gemfile`, Ruflet checks the bundle, installs missing
  dependencies, and loads the application with that bundle.

```bash
ruflet run
ruflet run main.rb --web
ruflet run apps/admin.rb --desktop --port 9000
ruflet run main.rb --no-reload
```

## Update managed clients

```text
ruflet update [web|desktop|all] [--check] [--force]
              [--platform macos|linux|windows]
```

With no target, Ruflet updates both web and desktop clients. `--check` reports
the installed release without downloading it. `--force` refreshes cached
assets. `--platform` selects the desktop release when it differs from the host
platform.

## Debug the Flutter client

```text
ruflet debug [platform] [--platform NAME] [--device-id ID]
             [--release] [-v|--verbose] [--web-renderer NAME]
```

`platform` can be `web`, `ios`, `android`, `macos`, `windows`, or `linux`.
`--device-id` selects a Flutter-visible device. `--release` uses release mode,
`--verbose` prints Flutter diagnostics, and `--web-renderer` forwards a web
renderer name. This command requires managed Flutter client source and is for
client-side debugging; normal app development uses `ruflet run`.

## Build

```text
ruflet build <apk|android|aab|ios|ipa|web|macos|windows|linux>
             [--lite|--full|--self] [-v|--verbose] [additional Flutter options]
```

`android` is an alias for an APK build, and `ipa` builds the uploadable iOS
archive. Builds are server-driven by default: the client connects to the
`app.backend_url` set in `ruflet.yaml`.

- A server-driven `apk`, `android`, `aab`, `ios`, or `ipa` build fails without
  `app.backend_url`.
- A `web`, `macos`, `windows`, or `linux` build can omit it. A web client then
  connects to the origin it was loaded from. A desktop client connects to the
  URL its launcher passes, as `ruflet run --desktop` does, or to
  `http://localhost:8550` when it is started without one. Set
  `app.backend_url` for a web build hosted apart from its Ruby backend and for
  a desktop build you distribute.

Self-contained builds embed the Ruby project:

- `--self` embeds it with the lite runtime. `--lite` selects the same profile.
- `--full` embeds full CRuby instead and implies `--self`. It needs a CRuby
  runtime distribution: set `RUFLET_FULL_RUNTIME_PATH`, or
  `build.full_runtime_path` in `ruflet.yaml`, to a `ruby_runtime` Flutter
  package whose `ruflet-full-runtime.json` lists the target platform. A
  project with a `Gemfile` also needs its `Gemfile.lock`, and the locked gems
  outside the `development` and `test` groups are packaged with the app.
- `--lite` and `--full` are mutually exclusive, and a web build cannot be
  self-contained.

Ruflet forwards remaining build options to Flutter after preparing extensions,
permissions, assets, and runtime mode.

## Install

```text
ruflet install [-d|--device DEVICE_ID] [-v|--verbose]
```

Install the last compatible build from `build/`. Run a platform build first.
Without a device id, Ruflet presents a numbered chooser for connected devices.

## Devices and emulators

```text
ruflet devices [Flutter device options]
ruflet emulators [-v|--verbose]
ruflet emulators --start --emulator ID [-v|--verbose]
```

`devices` lists Flutter-visible devices. `emulators` lists configured
emulators; `--start --emulator ID` launches one. Emulator creation and deletion
are not implemented by Ruflet, so use the Android or Apple platform tools for
those operations.

## Doctor

```text
ruflet doctor [--fix] [-v|--verbose]
```

Doctor reports Ruby, the managed template, Flutter, and platform-tool status.
`--fix` downloads supported missing Ruflet and Flutter assets. Platform SDKs,
signing identities, and system packages can still require manual setup.

## Exit status and diagnostics

Commands return zero on success and nonzero on invalid options, unsupported
targets, missing configuration, failed downloads, or failed platform tools.
Use `--verbose` where supported before reporting a build or tooling problem.

See [Configuration Reference](/docs/configuration-reference) for build keys and
[Build and Release](/docs/build-and-release) for delivery modes.
