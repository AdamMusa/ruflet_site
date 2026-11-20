# Running a Ruflet App

Run a project's Ruby entrypoint with the Ruflet CLI:

```bash
ruflet run main.rb
```

Mobile is the default target. Ruflet starts the Ruby server and prints the
connection details used by Ruflet Explorer.

## Web and desktop

```bash
ruflet run main.rb --web
ruflet run main.rb --desktop
```

The web command starts a same-origin local web client. The desktop command
starts the cached desktop client for the host platform.

## Script and port resolution

`main` and `main.rb` both resolve to the same entrypoint:

```bash
ruflet run main
ruflet run path/to/app.rb
ruflet run main.rb --port 9000
```

If the requested port is unavailable, Ruflet selects an available port and
prints the address it actually uses.

When a `Gemfile` is found, the run command checks the bundle and runs
`bundle install` if dependencies are missing.

## Debug the managed client

Use `ruflet debug` when you need to run the underlying Flutter client directly:

```bash
ruflet debug web
ruflet debug ios
ruflet debug --device-id chrome
```

Normal Ruby application development should use `ruflet run`.
