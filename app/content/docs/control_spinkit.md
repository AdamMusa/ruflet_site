# Spinkit

Animated loading indicators from the SpinKit collection, such as bouncing dots,
waves and pulsing circles. They come from the `spinkit` extension: add
`spinkit` to `extensions` in `ruflet.yaml` (see the
[SpinKit extension](/docs/extension-spinkit)).

## Example

```ruby
page.add(
  row(
    spacing: 24,
    children: [
      spinkit(three_bounce: { color: "#2563eb", size: 32 }),
      spinkit(fading_circle: { color: "#ea580c", size: 40, duration: 1000 }),
      spinkit(wave: { color: "#0d9488" })
    ]
  )
)
```

## Common properties

Pass exactly one variant keyword, and its options as a hash:

- variants: `rotating_circle`, `rotating_plain`, `double_bounce`, `wave`, `wandering_cubes`, `fading_four`, `fading_cube`, `pulse`, `chasing_dots`, `three_bounce`, `circle`, `cube_grid`, `fading_circle`, `folding_cube`, `pumping_heart`, `hour_glass`, `pouring_hour_glass`, `pouring_hour_glass_refined`, `fading_grid`, `ring`, `ripple`, `dual_ring`, `spinning_circle`, `spinning_lines`, `square_circle`, `three_in_out`, `dancing_square`, `piano_wave`, `pulsing_grid`, `wave_spinner`
- `color` — the indicator color
- `size` — the indicator size (default 50)
- `duration` — milliseconds for one animation cycle
- `line_width`, `border_width`, `item_count` and `wave_type`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

`spinkit` raises `ArgumentError` unless it gets exactly one variant, and when
the variant's options are not a hash. Use `spinkit(pulse: {})` for a variant
with its default look.
