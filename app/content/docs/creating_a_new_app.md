# Creating a New Ruflet App

Create a Ruby-first Ruflet project with:

```bash
ruflet new my_app
cd my_app
bundle install
bundle exec ruflet run main.rb
```

`ruflet create my_app` is an alias for `ruflet new my_app`.

## Generated files

```tree
my_app/
  Gemfile
  README.md
  main.rb
  ruflet.yaml
  services.yaml
  assets/
    icon.png
    splash.png
```

- `main.rb` contains the starter app and is the normal application entrypoint.
- `Gemfile` contains the Ruby runtime dependencies.
- `ruflet.yaml` configures app metadata, optional client extensions, assets, and builds.
- `services.yaml` declares protected device access such as camera or location.
- `assets/` contains the default icon and splash image.

## Run targets

Mobile is the default development target:

```bash
bundle exec ruflet run main.rb
```

Launch the managed web or desktop client with:

```bash
bundle exec ruflet run main.rb --web
bundle exec ruflet run main.rb --desktop
```

Use `bundle exec` inside an application so the CLI and runtime gems come from
that project's bundle.

## Next step

Read [App Structure](/docs/app-structure) to understand the generated
configuration, then [Running a Ruflet App](/docs/running-a-ruflet-app) for the
development loop.
