# SafeArea

Insets its content to avoid system intrusions — the status bar, notch, home
indicator, and rounded corners. Wrap your top-level screen content in it.

## Example

```ruby
safe_area(
  container(
    expand: true,
    padding: 16,
    content: column(children: [text("Hello"), filled_button(content: text("Go"))])
  ),
  expand: true
)
```

## Common properties

- `content` — the child control (also accepts a positional argument)
- `avoid_intrusions_top` / `avoid_intrusions_bottom` — keep clear of the status bar and notch, or the home indicator (both default `true`)
- `avoid_intrusions_left` / `avoid_intrusions_right` — keep clear of system areas on the sides, as in landscape (both default `true`)
- `minimum_padding` — padding kept on every side even where the system needs none: a number or `{ left:, top:, right:, bottom: }`
- `maintain_bottom_view_padding` — keep the bottom padding while the on-screen keyboard is open (default `false`)

## Usage

`safe_area` is typically the outermost control of a screen, with `expand: true`
so it fills the view. Disable a specific edge when you want content to run to
the screen edge there (for example a full-bleed image under the status bar).
