# CLI Workflow

The Ruflet CLI creates projects, runs development clients, prepares Flutter
tooling, builds applications, and installs build outputs.

## Commands

```text
ruflet --version
ruflet new <appname>
ruflet create <appname>
ruflet run [scriptname|path] [--web|--desktop] [--port PORT] [--no-reload]
ruflet update [web|desktop|all] [--check] [--force] [--platform PLATFORM]
ruflet debug [platform] [--device-id ID]
ruflet build <apk|android|ios|aab|web|macos|windows|linux> [--self] [--verbose]
ruflet install [--device DEVICE_ID] [--verbose]
ruflet devices
ruflet emulators
ruflet doctor [--fix] [--verbose]
ruflet help
```

Commands take no `--help` option: `ruflet new --help` creates a project
named `--help`. Use `ruflet help` and the
[CLI Reference](/docs/cli-reference) instead.

## Create and run

```bash
ruflet new my_app
cd my_app
bundle install
ruflet run main.rb
```

Mobile is the default run target. Use `--web` or `--desktop` to launch a
managed local client:

```bash
ruflet run main.rb --web
ruflet run main.rb --desktop
ruflet run main.rb --port 9000
```

The run command resolves `main` and `main.rb`, starts the Ruby server, and
prints the address used by the selected client.

Hot reload is on by default. While Ruflet is running, press `r` to rerun the
app against the current page or `R` to restart the Ruby backend. Pass
`--no-reload` when a watcher is not appropriate.

## Build and install

```bash
ruflet build apk
ruflet build ios
ruflet build web
ruflet build macos
```

Builds are server-driven by default and connect to `app.backend_url` in
`ruflet.yaml`. An `apk`, `android`, `aab`, `ios`, or `ipa` build fails when
`ruflet.yaml` sets no backend URL. The
[Configuration Reference](/docs/configuration-reference) lists the other keys
Ruflet reads, and the [CLI Reference](/docs/cli-reference) says when a web or
desktop build can omit it. Add `--self` to package the Ruby project with the
client:

```bash
ruflet build android --self
ruflet build ios --self
```

Install a compatible build on a connected device:

```bash
ruflet install
ruflet install --device emulator-5554
```

## Client updates

`ruflet update` manages cached prebuilt web and desktop clients:

```bash
ruflet update all
ruflet update web --check
ruflet update desktop --platform macos
ruflet update all --force
```

`ruflet run --web` and `ruflet run --desktop` also check for a newer client,
at most every six hours. Set `RUFLET_CLIENT_AUTO_UPDATE=0` to stop the
checks, `RUFLET_CLIENT_UPDATE_INTERVAL` to change the interval in seconds,
or `RUFLET_CLIENT_CHANNEL` to pick the release the clients come from; see
[Environment variables](/docs/configuration-reference#development-clients).

## Tooling commands

- `ruflet doctor` reports Ruby, Flutter, template, and platform-tool status.
- `ruflet doctor --fix` installs or downloads supported missing tooling.
- `ruflet devices` lists Flutter-visible devices.
- `ruflet emulators` lists emulators.
- `ruflet emulators --start --emulator ID` launches an emulator.
- `ruflet debug web` runs the managed Flutter client directly for client-side debugging.

See [CLI Reference](/docs/cli-reference) for every command option, alias,
default, and exit behavior.
