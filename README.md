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

The API reference targets Ruflet 0.0.19. `script/sync_ruflet_api` reads a
nearby Ruflet checkout or the installed gem and maintains the checked-in
control and service catalogs. Set `RUFLET_SOURCE_ROOT` to audit a particular
checkout. When Ruflet changes, regenerate the catalogs and update the reference
prose together so examples continue to describe the released APIs.
