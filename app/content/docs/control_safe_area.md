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
- `avoid_intrusions_top` / `avoid_intrusions_bottom`
- `avoid_intrusions_left` / `avoid_intrusions_right`
- `minimum_padding`
- `maintain_bottom_view_padding`

## Usage

`safe_area` is typically the outermost control of a screen, with `expand: true`
so it fills the view. Disable a specific edge when you want content to run to
the screen edge there (for example a full-bleed image under the status bar).
