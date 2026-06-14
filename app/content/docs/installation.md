# Installation

Ruflet requires Ruby and installs through RubyGems:

```bash
gem install ruflet
ruflet --version
```

Use `ruflet doctor` to inspect the local Ruby, Flutter, template, and platform
tooling:

```bash
ruflet doctor
ruflet doctor --fix
```

`--fix` downloads or installs supported missing tooling. Android, Apple, and
desktop builds can still require platform-specific SDKs, signing, or system
packages.

## Mobile development client

Install Ruflet Explorer to connect to `ruflet run` during mobile development:

- [Ruflet Explorer for iOS](https://apps.apple.com/us/app/ruflet-explorer/id6762528151)
- Android builds are available from the [Ruflet releases](https://github.com/AdamMusa/Ruflet/releases)

You do not need Ruflet Explorer for `--web`, `--desktop`, or packaged builds.

## Project dependencies

Projects created by `ruflet new` use Bundler and include the runtime gems in
their `Gemfile`. Run application commands through the project bundle:

```bash
bundle install
bundle exec ruflet run main.rb
```
