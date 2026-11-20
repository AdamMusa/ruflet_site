# Ruflet documentation website

This Rails application powers [ruflet.dev](https://ruflet.dev), including the
Ruflet guides, tutorials, and API reference.

Ruflet itself is a Ruby framework for building mobile, desktop, and web apps.
Install the CLI and start a project with:

```bash
gem install ruflet
ruflet new my_app
cd my_app
ruflet run main.rb --web
```

Ruflet commands are run directly with the `ruflet` executable. The CLI finds
the nearest `Gemfile` and prepares missing project dependencies when it runs an
application.

## Work on this website

```bash
bin/setup
bin/dev
```

Open `http://localhost:3000`. Documentation source lives in
`app/content/docs`; navigation and generated control pages are managed by
`app/models/docs_catalog.rb`.

Run the documentation checks with:

```bash
script/sync_ruflet_api --check
bin/rails test
```

The API reference targets Ruflet 0.0.23 as it stands on `main` (commit
`51bea9b`), which becomes the 0.0.24 release, rendered by ruflet-engine
`codex/engine-initialization` (commit `a463293`).

`script/sync_ruflet_api` maintains the checked-in control, service, and
runtime catalogs in `config/`. It reads two sources:

- Ruby controls and services from a Ruflet checkout
  ([AdamMusa/ruflet](https://github.com/AdamMusa/ruflet)), or from the
  installed `ruflet_core` gem. Set `RUFLET_SOURCE_ROOT` to choose a checkout.
- Extension contracts (maps, charts, video, and similar) from the Flutter
  renderer in [AdamMusa/ruflet-engine](https://github.com/AdamMusa/ruflet-engine).
  Set `RUFLET_ENGINE_ROOT` to choose a checkout. Without it, the script looks
  for a `ruflet-engine` directory next to the Ruflet checkout or this site.

```bash
RUFLET_SOURCE_ROOT=../ruflet RUFLET_ENGINE_ROOT=../ruflet-engine script/sync_ruflet_api
```

CI checks the catalogs against the exact Ruflet and ruflet-engine commits named
in `.github/workflows/ci.yml`. When you regenerate the catalogs, update those
two refs and the commits above, and update the reference prose in the same
change so examples keep describing the released APIs.
