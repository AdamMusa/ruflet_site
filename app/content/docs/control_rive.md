# Rive

Renders a [Rive](https://rive.app) animation from a `.riv` file — vector
animations and interactive state machines. Backed by the Flet
[`Rive`](https://flet.dev/docs/controls/rive/) extension, so the `rive`
extension must be enabled in `ruflet.yaml`:

```yaml
extensions:
  - rive
```

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

The first positional argument is the `src`, so
`rive("a.riv")` and `rive(src: "a.riv")` are equivalent. `src` may be a network
URL or a bundled asset path.

Drive a specific artboard and state machine:

```ruby
rive(
  "assets/character.riv",
  artboard: "Main",
  state_machines: ["State Machine 1"],
  use_artboard_size: true
)
```

## Properties

- `src` — **required** path to the `.riv` file (network URL or asset path).
- `placeholder` — a control shown while the file loads (e.g. `progress_ring()`).
- `artboard` — the name of the artboard to display; defaults to the file's main
  artboard.
- `animations` — an array of animation names to play.
- `state_machines` — an array of state machine names to run.
- `fit` — how the animation fits its box: `"contain"`, `"cover"`, `"fill"`,
  `"fit_width"`, `"fit_height"`, `"none"`, `"scale_down"`.
- `alignment` — alignment of the animation within its box
  (`{ x:, y: }`, each from -1.0 to 1.0).
- `speed_multiplier` — playback speed multiplier (default `1.0`).
- `use_artboard_size` — size the widget to the artboard's intrinsic size
  instead of the available space (default `false`).
- `enable_antialiasing` — enable anti-aliasing (default `true`).
- `headers` — a hash of HTTP headers used when fetching a network `src`.
- `clip_rect` — a clip rectangle (`{ left:, top:, right:, bottom: }`).
- `expand` — fill the available space in a `row`/`column`.
- `width` / `height` — fixed size when not expanding.
- `tooltip`, `visible`, `opacity`, `rtl`, `disabled` — the usual layout
  properties.

> Note: the Flet API names the artboard property `artboard` /
> `use_artboard_size`. The renderer reads `art_board` / `use_art_board_size` on
> the wire; the helper accepts either spelling and normalizes it for you.

Rive has no events or methods — playback is driven by `animations`,
`state_machines`, and `speed_multiplier`.

## Reference

- Family: `materials`
- Widget type: `rive`
- Helper: `rive`
