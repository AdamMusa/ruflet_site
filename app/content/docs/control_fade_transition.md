# FadeTransition

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

Fades its `content` from opacity `begin` to `end`. The client runs the
animation, so a loop such as a breathing loader needs no Ruby patch per frame.

## Example

```ruby
syncing = fade_transition(
  icon("cloud_sync", size: 48),
  begin: 0.3,
  end: 1,
  duration: 900,
  curve: "ease_in_out",
  repeat: true,
  reverse: true
)

page.add(syncing)
```

Stop the loop with `page.update(syncing, animating: false)`. A
`page.update` of `begin`, `end`, `duration` or `animating` retargets or pauses
the running animation.

## Properties

- `content` — the control to fade, as the first argument or `content:`.
- `begin` and `end` — the start and end opacity, from 0 to 1 (defaults 0 and 1).
- `duration` — milliseconds per run (default 1000).
- `curve` — an easing curve such as `"linear"`, `"ease_in_out"` or `"elastic_out"`.
- `delay` — milliseconds to wait before the first run.
- `repeat` — loop the animation.
- `reverse` — with `repeat: true`, play back and forth.
- `animating` — `false` pauses the animation.

## Events

- `on_animation_end` — a run that does not repeat finished.

The other explicit transitions, `scale_transition`, `slide_transition`,
`size_transition` and `rotation_transition`, take the same timing keywords.
See [Controls and Layout](/docs/controls-and-layout#transitions-clips-and-sizing-boxes).
