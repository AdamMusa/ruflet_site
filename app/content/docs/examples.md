# Examples

The Ruflet repo already ships a strong set of examples. If you want to learn the framework quickly, start here before building everything from scratch.

## How to run examples

From the examples folder:

```bash
bundle install
ruflet run main
ruflet run calculator
ruflet run solitaire
ruflet run todo
ruflet run dialog
ruflet run image_gallery
```

## Starter examples

- `hello_world.rb`: smallest class-based example
- `counter.rb`: smallest `Ruflet.run` example
- `main.rb`: app shell with multiple common controls
- `navigation.rb`: navigation structure and route-driven patterns

## Productivity examples

- `todo.rb`: lists, filters, actions, and local state updates
- `calculator.rb`: buttons, layout, and event handling
- `dialog.rb`: alert dialogs, bottom sheets, banners, and feedback surfaces

## UI pattern examples

- `tabs.rb`: top tabs plus a bottom navigation bar
- `image_gallery.rb`: media layout and image presentation

## Showcase examples

- `solitaire.rb`: a larger interactive app with richer state and composition
- Ruflet Studio: an internal gallery app covering controls, charts, services, media, and utilities

## What Ruflet Studio demonstrates

Ruflet Studio is especially valuable because it exercises features beyond the smallest demos:

- Material controls
- Cupertino controls
- counters, calculators, and todo flows
- charts
- drawing/canvas-style features
- web view, audio, video, battery, flashlight, connectivity, camera
- file picker, clipboard, share, storage paths
- icon search and more advanced utility screens

## Best learning path

1. Run `counter.rb` or `hello_world.rb`.
2. Move to `dialog.rb` and `tabs.rb`.
3. Open `todo.rb` for a realistic stateful example.
4. Browse Ruflet Studio when you want to see broader feature coverage.

## Use examples as documentation

Ruflet is still growing, so examples are not just demos. They are one of the best sources of truth for:

- naming conventions
- current helper function shapes
- event/update patterns
- how services are wired in practice
