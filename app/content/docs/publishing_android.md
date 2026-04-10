# Android

Ruflet can package Android builds through the CLI.

## Build commands

```bash
ruflet build apk
ruflet build android --self
ruflet build aab
```

## Choosing a mode

- Use the default mode when the app will talk to a hosted Ruflet backend.
- Use `--self` when you want a more self-contained client build.

## Things to decide early

- which services/extensions your app needs
- whether runtime logic stays server-driven or embedded
- your asset setup in `ruflet.yaml`

## Install after building

```bash
ruflet install
```

For device-specific install flows, use `--device`.
