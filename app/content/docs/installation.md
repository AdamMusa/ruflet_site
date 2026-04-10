# Installation

Ruflet is installed from RubyGems.

## Install the CLI

```bash
gem install ruflet
```

## Important package rename

If you have older notes or examples, the install command changed:

- old: `gem install ruflet_cli`
- current: `gem install ruflet`

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
