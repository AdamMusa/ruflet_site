# Rive

Renders a [Rive](https://rive.app) animation from a `.riv` file: vector
animations and interactive state machines that react to the user's touches. It
is provided by the `ruflet_rive` client extension, so enable `rive` in
`ruflet.yaml` and rebuild the client:

```yaml
extensions:
  - rive
```

It looks the same on every platform.

## Example

```ruby
rive(
  "https://cdn.rive.app/animations/vehicles.riv",
  width: 300,
  height: 300,
  fit: "contain",
  speed_multiplier: 1.0,
  placeholder: progress_ring()
)
```

The first positional argument is the `src`, so `rive("a.riv")` and
`rive(src: "a.riv")` are equivalent. `src` is a network URL, a path in your
app's assets or a file path on the device.

Drive a specific artboard and state machine:

```ruby
rive(
  "assets/character.riv",
  art_board: "Main",
  state_machines: ["State Machine 1"],
  use_art_board_size: true
)
```

## Properties

- `src` — **required** path to the `.riv` file (network URL, asset path or file
  path). Without it the control draws an error box, and so does a file that
  fails to load.
- `placeholder` — a control shown while the file loads (e.g. `progress_ring()`).
- `art_board` — the name of the artboard to display; defaults to the file's
  default artboard.
- `animations` — an array of animation names to play.
- `state_machines` — an array of state machine names to run. State machines
  receive the user's taps and pointer moves, so their listeners work. With
  neither `animations` nor `state_machines`, the artboard's default state
  machine runs, or else its first animation.
- `fit` — how the artboard fits its box: `"contain"` (the default), `"cover"`,
  `"fill"`, `"fitWidth"`, `"fitHeight"`, `"none"` or `"scaleDown"`. Write the
  names as shown: 0.0.23 does not read `"fit_width"`.
- `alignment` — alignment of the artboard within its box (`{ x:, y: }`, each
  from -1.0 to 1.0; default centered).
- `speed_multiplier` — playback speed multiplier (default `1.0`).
- `use_art_board_size` — size the widget to the artboard's own size instead of
  the available space (default `false`).
- `headers` — a hash of HTTP headers used when fetching a network `src`.
- `clip_rect` — show only part of the artboard:
  `{ left:, top:, right:, bottom: }` in artboard pixels.
- `expand` — fill the available space in a `row`/`column`.
- `width` / `height` — fixed size when not expanding.
- `tooltip`, `visible`, `opacity`, `rtl`, `disabled` — the usual layout
  properties.

Use the Ruflet wire names `art_board` and `use_art_board_size`; the current DSL
passes extension properties through without renaming them.

Rive has no events of its own and no methods: playback is driven by
`animations`, `state_machines` and `speed_multiplier`, and the control picks up
new values you send with `page.update`.

## Reference

- Family: `materials`
- Widget type: `rive`
- Helper: `rive`
