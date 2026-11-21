# CLI Reference

This reference describes the Ruflet command-line interface. Run Ruflet
commands directly with the installed `ruflet` executable.

```text
ruflet <command> [arguments] [options]
```

Use `ruflet help` or `ruflet --help` for the command summary. Use
`ruflet --version`, `ruflet -v`, or `ruflet version` to print the installed
version.

In 0.0.23 commands have no help of their own; `ruflet help build` prints the
same summary. Do not pass `--help` to a command there, because the command
treats it as an argument:

- `ruflet new --help` and `ruflet create --help` create a project in a directory named `--help`.
- `ruflet build --help` stops with `Unsupported build target: --help`.
- `ruflet install --help` looks for a build to install.
- `ruflet doctor --help` runs the doctor.
- `ruflet devices --help` passes `--help` to Flutter, which prints the help of `flutter devices` and lists no devices.
- `ruflet run --help`, `ruflet update --help`, `ruflet debug --help` and `ruflet emulators --help` print only a bare list of options under `Usage: ruflet [options]`.

This reference lists each command's options.

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). `ruflet <command> --help`, `-h` and `ruflet help <command>` print that command's usage, summary and options. A flag the command does not read stops it with `ruflet <command>: invalid option: <flag>` and the command's help on standard error, exit status 64. `build` and `devices` still pass the flags they do not read to Flutter, so `ruflet build apk --help` and `ruflet devices --help` reach Flutter.

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
- The server listens on port `8550` by default, or on the next free port when
  that one is taken. `--port PORT` sets the port to start from. `ruflet run`
  passes the port it picked to the app as `RUFLET_PORT`, in place of any value
  already set, so `RUFLET_PORT` sets the port only for an app started without
  `ruflet run`.
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

`--device ID` and `--device=ID` are other spellings of `--device-id ID`.

## Build

```text
ruflet build <apk|android|aab|ios|ipa|web|macos|windows|linux>
             [--lite|--full|--self] [-v|--verbose] [additional Flutter options]
```

`android` is an alias for an APK build, and `ipa` builds the uploadable iOS
archive. Builds are server-driven by default: the client connects to the
`app.backend_url` set in `ruflet.yaml`.

- A server-driven `apk`, `android`, `aab`, `ios`, or `ipa` build fails when
  `ruflet.yaml` sets no backend URL. Set `app.backend_url`; the
  [Configuration Reference](/docs/configuration-reference) lists the other
  keys Ruflet also reads. A value without an `http`, `https`, `ws`, or `wss`
  scheme, or without a host, counts as unset.
- A `web`, `macos`, `windows`, or `linux` build can omit the backend URL. A
  web client then connects to the origin it was loaded from. A desktop client
  connects to the URL its launcher passes, as `ruflet run --desktop` does, or
  to `http://localhost:8550` when it is started without one. Set
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
permissions, assets, and runtime mode. Ruflet's own flags may sit anywhere,
but the first other argument is the target, so put Flutter's flags after it:
`ruflet build apk --release`.

The target may also come after Flutter's flags, as in `ruflet build --release apk`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Install

```text
ruflet install [-d|--device DEVICE_ID] [-v|--verbose]
```

Install the last compatible build from `build/`. Run a platform build first.
Without a device id, Ruflet presents a numbered chooser for connected devices.

`--device=DEVICE_ID` is read too, and `-d` without a device id is an error. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

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

`--cold` with `--start --emulator ID` cold boots an Android emulator. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Doctor

```text
ruflet doctor [--fix] [-v|--verbose]
```

Doctor reports Ruby, the managed template, Flutter, and platform-tool status.
`--fix` downloads supported missing Ruflet and Flutter assets. Platform SDKs,
signing identities, and system packages can still require manual setup.

Without `--fix`, the doctor installs no Flutter. It still finds a Flutter SDK
that `--fix` or a build installed earlier under
`~/.ruflet/flutter/<version>/<host>/flutter`. With an exact `x.y.z` version
from `RUFLET_FLUTTER_VERSION` or `.fvmrc`, only that version counts and
another installed version is not used; otherwise it uses the newest installed
SDK, a stable release first on the stable channel. 0.0.23 reports
`Flutter: missing` unless Flutter is on your `PATH` (with no pinned version)
or, for a pinned version, in the project's FVM directory. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

When Ruflet needs its own Flutter SDK but cannot download Flutter's release
list (offline, or an error answer), `ruflet doctor --fix` and the commands
that need Flutter (`build`, `install`, `debug`, `devices`, `emulators` and
`update`) use an SDK already installed there instead of failing. They pick it
the same way: only the pinned version when you pin an exact `x.y.z`,
otherwise the newest. With 0.0.23 they stop and report that Flutter is
required and the FVM bootstrap failed. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Environment variables

Commands also read these environment variables. The
[Configuration Reference](/docs/configuration-reference#environment-variables)
describes each one.

- `new`, `create`, `build`, `install`, `debug`, `update` and `doctor` refresh the downloaded client template before they run. `RUFLET_TEMPLATE_REPO_URL`, `RUFLET_TEMPLATE_REPO_REF` and `RUFLET_CACHE_DIR` choose where it comes from and where it is kept. `RUFLET_TEMPLATE_ROOT` makes `new` and `build` copy a local template instead, and `doctor` reports it.
- `run`: `RUFLET_CLIENT_AUTO_UPDATE`, `RUFLET_CLIENT_UPDATE_INTERVAL` and `RUFLET_CLIENT_CHANNEL` control the prebuilt web and desktop clients, which `update` also reads.
- `build`: `RUFLET_CONFIG`, `RUFLET_CLIENT_DIR`, `RUFLET_FLUTTER_VERSION`, `RUFLET_FULL_RUNTIME_PATH`, `RUFLET_RUBY_RUNTIME_PATH`, `RUFLET_MRBC`, `RUFLET_IOS_TEAM_ID` and the `RUFLET_ANDROID_*` signing variables.
- The running app: `RUFLET_HOST`, `RUFLET_STRICT_PORT`, `RUFLET_PROTOCOL_TRACE` and `RUFLET_DEBUG`, and in Rails `RUFLET_RAILS_DEBUG_EVENTS`.

## Exit status and diagnostics

Commands return zero on success and nonzero on invalid options, unsupported
targets, missing configuration, failed downloads, or failed platform tools.
An invalid option exits with status 64. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
Use `--verbose` where supported before reporting a build or tooling problem.
`RUFLET_PROTOCOL_TRACE=summary` prints the messages a running app exchanges
with its client.

See [Configuration Reference](/docs/configuration-reference) for build keys and
[Build and Release](/docs/build-and-release) for delivery modes.
