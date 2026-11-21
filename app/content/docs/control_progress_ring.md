# ProgressRing

A circular progress indicator. Leave `value` unset for an indeterminate spinner,
or set it (0.0–1.0) for determinate progress. Use `progress_bar` for a linear
bar.

## Example

```ruby
# indeterminate spinner
progress_ring()

# determinate (60%)
progress_ring(value: 0.6, stroke_width: 4)
```

## Common properties

- `value` — `nil` (spinner) or `0.0`–`1.0`
- `color`
- `bgcolor` / `stroke_width` / `stroke_cap` / `stroke_align` — Android, web, Windows and Linux only; iOS and macOS draw an activity indicator
- `size_constraints` / `padding` / `track_gap` — Android, web, Windows and Linux only; `track_gap` shows only with `year_2023: false`
- `radius` / `animating` — iOS and macOS only: the size of the activity indicator (default 10) and whether an indeterminate one spins (default `true`)
- `semantics_label` — on iOS and macOS it needs the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `year_2023` — `false` gives the newer Material look on Android, web, Windows and Linux. The 0.0.23 client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `progress` — the iOS name for `value`; when both are set, `progress` wins. On Android, web, Windows and Linux, the 0.0.23 client ignores it, so use `value` there. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS a determinate ring is an activity indicator whose spokes
appear one by one as `value` grows. `cupertino_activity_indicator` sends the
same `ProgressRing` control; see
[CupertinoActivityIndicator](/docs/control-cupertino-activity-indicator).

## Usage

Show a spinner while loading, then swap in content:

```ruby
body = column(children: [progress_ring()])
page.add(body)

records = load_records          # slow work
page.update(body, children: records.map { |r| text(r.name) })
```

For a horizontal bar, `progress_bar(value: 0.6)`.
