# Running a Ruflet App

Ruflet's default development loop is intentionally simple.

## Default run command

```bash
ruflet run main
```

This starts the Ruflet backend in mobile mode by default.

## Targeting web or desktop

```bash
ruflet run main --web
ruflet run main --desktop
```

## What Ruflet does for you

- resolves `main` and `main.rb`
- checks the nearest `Gemfile`
- runs `bundle install` if dependencies are missing
- starts the local Ruflet backend
- prints connection information for the selected target
- opens a web or desktop client when appropriate

## Port selection

You can override the default port:

```bash
ruflet run main --port 9000
```

If the requested port is busy, Ruflet will choose another available one and tell you which port it used.

## Typical loop

1. Start the app with `ruflet run`.
2. Edit your Ruby files.
3. Refresh or reconnect the client as needed.
4. Repeat until the flow is right.

## When to use `ruflet debug`

Use `ruflet debug` when you need to work with the underlying Flutter client more directly instead of staying in the normal Ruby-first loop.
