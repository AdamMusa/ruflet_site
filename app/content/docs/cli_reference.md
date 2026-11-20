# CLI Reference

This reference describes the Ruflet 0.0.19 command-line interface. Run Ruflet
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
ruflet build <apk|android|ios|aab|web|macos|windows|linux>
             [--self] [-v|--verbose] [additional Flutter options]
```

`android` is an alias for an APK build. Builds are server-driven by default and
require a reachable backend URL. `--self` embeds the Ruby project for a
self-contained build. Ruflet forwards remaining build options to Flutter after
preparing extensions, permissions, assets, and runtime mode.

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
