# CLI Workflow

The Ruflet CLI creates projects, runs development clients, prepares Flutter
tooling, builds applications, and installs build outputs.

## Commands

```text
ruflet --version
ruflet new <appname>
ruflet create <appname>
ruflet run [scriptname|path] [--web|--desktop] [--port PORT]
ruflet update [web|desktop|all] [--check] [--force] [--platform PLATFORM]
ruflet debug [platform] [--device-id ID]
ruflet build <apk|android|ios|aab|web|macos|windows|linux> [--self] [--verbose]
ruflet install [--device DEVICE_ID] [--verbose]
ruflet devices
ruflet emulators
ruflet doctor [--fix] [--verbose]
```

## Create and run

```bash
ruflet new my_app
cd my_app
bundle install
bundle exec ruflet run main.rb
```

Mobile is the default run target. Use `--web` or `--desktop` to launch a
managed local client:

```bash
bundle exec ruflet run main.rb --web
bundle exec ruflet run main.rb --desktop
bundle exec ruflet run main.rb --port 9000
```

The run command resolves `main` and `main.rb`, starts the Ruby server, and
prints the address used by the selected client.

## Build and install

```bash
bundle exec ruflet build apk
bundle exec ruflet build ios
bundle exec ruflet build web
bundle exec ruflet build macos
```

Builds are server-driven by default and require `app.backend_url` in
`ruflet.yaml`. Add `--self` to package the Ruby project with the client:

```bash
bundle exec ruflet build android --self
bundle exec ruflet build ios --self
```

Install a compatible build on a connected device:

```bash
bundle exec ruflet install
bundle exec ruflet install --device emulator-5554
```

## Client updates

`ruflet update` manages cached prebuilt web and desktop clients:

```bash
ruflet update all
ruflet update web --check
ruflet update desktop --platform macos
ruflet update all --force
```

## Tooling commands

- `ruflet doctor` reports Ruby, Flutter, template, and platform-tool status.
- `ruflet doctor --fix` installs or downloads supported missing tooling.
- `ruflet devices` lists Flutter-visible devices.
- `ruflet emulators` lists emulators.
- `ruflet emulators --start --emulator ID` launches an emulator.
- `ruflet debug web` runs the managed Flutter client directly for client-side debugging.
