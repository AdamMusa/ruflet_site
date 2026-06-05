# Installation

Ruflet is installed from RubyGems.

## Install Ruflet Explorer

Ruflet Explorer is the mobile companion app used to connect to a local or hosted Ruflet app while you are developing.

- ![iOS](/assets/platform_ios.svg) **iOS:** download [Ruflet Explorer on the App Store](https://apps.apple.com/us/app/ruflet-explorer/id6762528151).
- ![Android](/assets/platform_android.svg) **Android:** Google Play is coming soon. For now, download the Android build from the [Ruflet GitHub releases page](https://github.com/AdamMusa/Ruflet/releases).

## Install the CLI

```bash
gem install ruflet
```

The app projects created by Ruflet still use runtime gems inside the generated `Gemfile`, but the command-line entrypoint you install globally is now `ruflet`.

## Verify the install

```bash
ruflet --version
```

## What gets installed into an app later

When you run `ruflet new`, the generated project uses runtime gems such as:

- `ruflet_core`
- `ruflet_server`

That split keeps the CLI package focused on project tooling while the app itself carries the runtime dependencies it actually needs.

## Next step

Continue with Creating a New Ruflet App.
